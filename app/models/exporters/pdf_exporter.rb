require 'prawn/document'

module Exporters
  class PDFExporter < BaseExporter
    extend BaseSelectFields

    class << self
      def id
        'case_pdf'
      end

      def mime_type
        'pdf'
      end

      def supported_models
        [Child]
      end

      def excluded_forms
        FormSection.binary_form_names
      end

      def export(cases, properties_by_module, current_user, custom_export_options, *args)
        unless custom_export_options.present?
          properties_by_module = exclude_forms(properties_by_module) if self.excluded_forms.present?
        end
        properties_by_module = filter_custom_exports(properties_by_module, custom_export_options)

        pdf = Prawn::Document.new(:info => {
          :Title => "Primero Child Export",
          :Author => "Primero",
          :Subject => "Ids: " + (cases.map {|c| c.case_id}.join(', ')),
          :CreationDate => Time.now,
        })

        form_sections = form_sections_by_module(cases, current_user)

        cases.each do |cs|
          pdf.start_new_page if pdf.page_number > 1
          start_page = pdf.page_number
          pdf.outline.section(section_title(cs), :destination => pdf.page_number)
          render_case(pdf, cs, form_sections[cs.module.name], properties_by_module[cs.module.id])
          end_page = pdf.page_number
          print_heading(pdf, cs, start_page, end_page)
        end

        pdf.render
      end

      def print_heading(pdf, _case, start_page, end_page)
        if end_page > start_page
          for i in (start_page + 1)..end_page
            pdf.go_to_page(i)
            pdf.bounding_box([pdf.bounds.right-50, pdf.bounds.top + 15], :width => 50) do
              pdf.text "#{_case.short_id}"
            end
          end
        end
      end

      def form_sections_by_module(cases, current_user)
        cases.map(&:module).compact.uniq.inject({}) do |acc, mod|
          acc.merge({mod.name => FormSection.get_permitted_form_sections(mod, 'case', current_user)
                                       .select(&:visible)
                                       .sort {|a, b| [a.order_form_group, a.order] <=> [b.order_form_group, b.order] } })
        end
      end

      def section_title(_case)
        _case.short_id
      end

      def render_case(pdf, _case, base_subforms, prop)
        #Only print the case if the case's module matches the selected module
        if prop.present?
          base_subforms = base_subforms.select{|sf| prop.keys.include?(sf.name)}

          render_title(pdf, _case)

          grouped_subforms = base_subforms.group_by(&:form_group_name)

          pdf.outline.add_subsection_to(section_title(_case)) do
            grouped_subforms.each do |(parent_group, fss)|
              pdf.outline.section(parent_group, :destination => pdf.page_number, :closed => true) do
                fss.each do |fs|
                  pdf.text fs.name, :style => :bold, :size => 16
                  pdf.move_down 10

                  pdf.outline.section(fs.name, :destination => pdf.page_number)

                  render_form_section(pdf, _case, fs, prop)

                  pdf.move_down 10
                end
              end
            end
          end
        end
      end

      def render_title(pdf, _case)
        pdf.text section_title(_case), :style => :bold, :size => 20, :align => :center
      end

      def render_form_section(pdf, _case, form_section, prop)
        (subforms, normal_fields) = form_section.fields.reject {|f| f.type == 'separator' || f.visible? == false}
                                                       .partition {|f| f.type == Field::SUBFORM }

        render_fields(pdf, _case, normal_fields)

        subforms.map do |subf|
          pdf.move_down 10
          form_data = _case.__send__(subf.name)
          filtered_subforms = subf.subform_section.fields.reject {|f| f.type == 'separator' || f.visible? == false}

          pdf.text subf.display_name, :style => :bold, :size => 12

          if prop[form_section.name].count == 1 && prop[form_section.name][subf.subform_section_id].present?
            render_blank_subform(pdf, filtered_subforms)
          else
            if (form_data.try(:length) || 0) > 0
              form_data.each do |el|
                render_fields(pdf, el, filtered_subforms)
                pdf.move_down 10
              end
            else
              render_blank_subform(pdf, filtered_subforms)
            end
          end
        end
      end

      def render_blank_subform(pdf, subforms)
        render_fields(pdf, nil, subforms)
        pdf.move_down 10
      end

      def render_fields(pdf, obj, fields)
        table_data = fields.map do |f|
          if obj.present?
            value = censor_value(f.name, obj)
            [f.display_name, format_field(f, value)]
          else
            [f.display_name, nil]
          end
        end

        table_options = {
          :row_colors => %w[  cccccc ffffff  ],
          :width => 500,
          :column_widths => {0 => 200, 1 => 300},
          :position => :left,
        }

        pdf.table(table_data, table_options) if table_data.length > 0
      end

      def censor_value(attr_name, obj)
        case attr_name
        when 'name'
          obj.try(:hidden_name) ? '***hidden***' : obj.name
        else
          obj.__send__(attr_name)
        end
      end

      def format_field(field, value)
        case value
        when TrueClass, FalseClass
          value ? {:image => Rails.root.join("app/assets/images/icon-tick.png")} : ""
        when String
          value
        when DateTime
          value.strftime("%d-%b-%Y")
        when Date
          value.strftime("%d-%b-%Y")
        when Array
          value.map {|el| format_field(field, el) }.join(', ')
        #when Hash
          #value.inject {|acc, (k,v)| acc.merge({ k => format_field(field, v) }) }
        else
          value.to_s
        end
      end
    end
  end
end
