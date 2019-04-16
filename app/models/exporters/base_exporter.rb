
module Exporters
  private

  class BaseExporter

    EXPORTABLE_FIELD_TYPES = [
      Field::TEXT_FIELD,
      Field::TEXT_AREA,
      Field::RADIO_BUTTON,
      Field::SELECT_BOX,
      Field::NUMERIC_FIELD,
      Field::DATE_FIELD,
      Field::DATE_RANGE,
      Field::TICK_BOX,
      Field::TALLY_FIELD,
      Field::SUBFORM
    ]

    class << self
      #extend Memoist

      public

      def id
        raise NotImplementedError
      end

      def supported_models
        ApplicationRecord.descendants
      end

      def mime_type
        id
      end

      def excluded_properties
        Field.binary_fields.pluck(:name)
      end

      def excluded_forms
        []
      end

      def authorize_fields_to_user?
        true
      end

      #This is a class method that does a one-shot export to a String buffer.
      #Don't use this for large datasets.
      def export(*args)
        exporter_obj = new()
        exporter_obj.export(*args)
        exporter_obj.complete
        return exporter_obj.buffer.string
      end

      def properties_to_export(props)
        props = exclude_forms(props) if self.excluded_forms.present?
        props = props.flatten.uniq
        props.reject! {|p| self.excluded_properties.include?(p.try(:name)) } if self.excluded_properties.present?
        return props
      end

      def exclude_forms(props)
        filtered_props = {}
        if props.is_a?(Hash)
          props.each do |mod, forms|
            forms = forms.to_h.reject do |form_name, _|
              self.excluded_forms.include?(form_name)
            end
            filtered_props[mod] = forms
          end
        else
          filtered_props = props
        end
        return filtered_props
      end

      # TODO: Make this method generic
      def case_form_sections_by_module(cases, current_user)
        cases.map(&:module).compact.uniq.inject({}) do |acc, mod|
          acc.merge({mod.name => FormSection.get_permitted_form_sections(mod, 'case', current_user)
                                      .select(&:visible)
                                      .sort {|a, b| [a.order_form_group, a.order] <=> [b.order_form_group, b.order] } })
        end
      end

      def properties_to_keys(props)
        #This flattens out the properties by modules by form,
        # while maintaining form order and discarding dupes
        if props.present?
          if props.is_a?(Hash)
            props.reduce({}) do |acc1, primero_module|
              hash = primero_module[1].reduce({}) do |acc2, form|
                acc2.merge(form[1])
              end
              acc1.merge(hash)
            end.values
          else
            props
          end
        else
          []
        end
      end

      ## Add other useful information for the report.
      def include_metadata_properties(props, model_class)
        props.each do |pm, fs|
          #TODO: Does order of the special form matter?
          props[pm].merge!(model_class.record_other_properties_form_section)
        end
        return props
      end

      def current_model_class(models)
        if models.present? && models.is_a?(Array)
          models.first.class
        end
      end

      # @param properties: array of CouchRest Model Property instances
      def to_2D_array(models, properties)
        emit_columns = lambda do |props, parent_props=[], &column_generator|
          props.map do |p|
            prop_tree = parent_props + [p]
            if p.type.eql?("subform")
              # TODO: This is a hack for CSV export, that causes memory leak
              # 5 is an arbitrary number, and probably should be revisited
              longest_array = 5 #find_longest_array(models, prop_tree)
              (1..(longest_array || 0)).map do |n|
                new_prop_tree = prop_tree.clone + [n]
                if p.type.eql?("subform")
                  emit_columns.call(p.subform.fields, new_prop_tree, &column_generator)
                else
                  column_generator.call(new_prop_tree)
                end
              end.flatten
            else
              if !p.type.nil? && p.type.eql?("subform")
                emit_columns.call(p.subform.fields, prop_tree, &column_generator)
              else
                column_generator.call(prop_tree)
              end
            end
          end.flatten
        end

        header_columns = ['id', 'model_type'] + emit_columns.call(properties) do |prop_tree|
          pt = prop_tree.clone
          init = pt.shift.name
          pt.inject(init) do |acc, prop|
            if prop.is_a?(Numeric)
              "#{acc}[#{prop}]"
            else
              "#{acc}#{prop.name}"
            end
          end
        end

        yield header_columns

        models.each do |m|
          # TODO: RENAME Child to Case like we should have done months ago
          model_type = {'Child' => 'Case'}.fetch(m.class.name, m.class.name)
          row = [m.id, model_type] + emit_columns.call(properties) do |prop_tree|
            translate_value(prop_tree, get_value_from_prop_tree(m, prop_tree))
          end

          yield row
        end
      end

      #def find_longest_array(models, prop_tree)
      #  models.map {|m| (get_value_from_prop_tree(m, prop_tree) || []).length }.max
      #end
      # this memoization causes memory leaks and brakes when exporting 10k records
      #memoize :find_longest_array

      # TODO: axe this in favor of the similar function in the Accessible model
      # concern.  Have to figure out the inheritance tree for the models first
      # so that all exportable models get that method.
      def get_value_from_prop_tree(model, prop_tree)
        prop_tree.inject(model) do |acc, prop|
          if acc.nil?
            nil
          elsif prop.is_a?(Numeric)
            # We use 1-based numbering in the output but arrays in Ruby are
            # still 0-based
            acc[prop - 1]
          else
            acc["data"].present? ? acc["data"][prop.try(:name)] : acc[prop.try(:name)]
          end
        end
      end

      #Date field in the index page are displayed with some format
      #and they should be exported using the same format.
      def to_exported_value(value)
        if value.is_a?(Date)
          I18n.l(value)
        elsif value.is_a?(Time)
          I18n.l(value, format: :with_time)
        else
          #Returns original value.
          value
        end
      end

      def get_model_value(model, property)
        exclude_name_mime_types = ['xls', 'csv', 'selected_xls']
        if property.name == 'name' && model.try(:module_id) == PrimeroModule::GBV && exclude_name_mime_types.include?(id)
          "*****"
        else
          value = model.send(property.name)
          translate_value(property.name, value)
        end
      end

      def map_field_to_translated_value(field, value)
        if field.present? && [Field::RADIO_BUTTON, Field::SELECT_BOX, Field::TICK_BOX].include?(field.type)
          if value.is_a?(Array)
            value.map{|v| field.display_text(v) }
          else
            field.display_text(value)
          end
        else
          to_exported_value(value)
        end
      end

      def translate_value(prop_name, value)
        name = prop_name.is_a?(Array) ? prop_name[0].try(:name) : prop_name
        field = @fields.select{|f| f.name == name}.first if @fields.present?

        if field.present?
          if prop_name.is_a?(Array) && field.type == Field::SUBFORM
            prop_names = prop_name.map{|pn| pn.try(:name)}
            sub_fields = field.subform_section.try(:fields)
            sub_field = sub_fields.select{|sf| prop_names.include?(sf.name)}.first
            map_field_to_translated_value(sub_field, value)
          else
            map_field_to_translated_value(field, value)
          end
        else
          value
        end
      end

      def get_model_location_value(model, property)
        Location.ancestor_placename_by_name_and_admin_level(model.send(property.first.try(:name)), property.last[:admin_level].to_i) if property.last.is_a?(Hash)
      end

      def load_fields(props)
        # TODO: Will change when permitted_properties method from user is ready
        @fields = Field.where(id: props.pluck(:id))
      end
    end

    def initialize(output_file_path=nil)
      @io = if output_file_path.present?
        File.new(output_file_path, "w")
      else
        StringIO.new
      end
    end

    def export(*args)
      raise NotImplementedError
    end

    def complete
      if self.buffer.class == File
        @io.close unless self.buffer.closed?
      end
    end

    def buffer
      return @io
    end
  end
end
