module FieldsHelper

  def option_fields_for form, suggested_field
    return [] unless suggested_field.field.option_strings.present?
    suggested_field.field.option_strings.collect do |option_string|
      form.hidden_field("option_strings_text", { :multiple => true, :id => "option_string_" + option_string, :value => option_string+"\n" })
    end
  end

	def display_options field
		field.option_strings.collect { |f| '"'+f+'"' }.join(", ")
	end

	def forms_for_display
	  FormSection.all.sort_by{ |form| form.name || "" }.map{ |form| [form.name, form.unique_id] }
	end

  def field_tag_name(object, field, field_keys=[])
    if field_keys.present?
      "#{object.class.name.downcase}[#{field_keys.join('][')}]"
    else
      field.tag_name_attribute(object.class.name.downcase)
    end
  end

  def field_value(object, field, field_keys=[])
    if field_keys.present? && !object.new?
      field_value = object
      field_keys.each {|k| field_value = field_value[k]}
    else
      if field == 'status'
        return 'Open'
      elsif field.type == Field::DATE_RANGE
        return [object["#{field.name}_from"], object["#{field.name}_to"]]
      else
        field_value = object[field.name] || ''
      end
    end
    return field_value
  end
  
  def field_keys(subform_name, subform_index, field_name, form_group_name)
    field_key = []
  
    if form_group_name.present? and form_group_name == "Violations"
      field_key << form_group_name.downcase
    end
    
    if subform_name.present?
      field_key << subform_name << subform_index
    end
    
    field_key << field_name
    
    return field_key 
  end

  def subforms_count(object, field, form_group_name)
    subforms_count = 0
    if object[field.name].present?
      subforms_count = object[field.name].count
    elsif object[form_group_name.downcase].present? && object[form_group_name.downcase][field.name].present?
      subforms_count = object[form_group_name.downcase][field.name].count
    end
    return subforms_count
  end
  
  def get_subform_object(object, subform_section, form_group_name)
    subform_object = {}
    if form_group_name.present? and form_group_name == "Violations"
      subform_object = object[form_group_name.downcase][subform_section.unique_id]
    else
      subform_object = object[:"#{subform_section.unique_id}"]
    end
    return subform_object
  end

end
