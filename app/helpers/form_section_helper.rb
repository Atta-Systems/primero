module FormSectionHelper
  def sorted_highlighted_fields
    FormSection.sorted_highlighted_fields
  end

  def url_for_form_section_field(form_section_id, field)
    field.new? ? form_section_fields_path(form_section_id) : form_section_field_path(form_section_id, field.name)
  end

  def url_for_form_section(form_section)
    form_section.new? ? form_sections_path : form_section_path(form_section.unique_id)
  end

  def build_form_tabs(group, forms, show_summary = false)
    form = forms.first
    if forms.count > 1
      content_tag :li, class: 'group' do
        concat(
          link_to("#tab_#{form.section_name}", class: 'group') do
            concat(t(group, :default => group))
          end
        )
        concat(build_group_tabs(forms))
      end
    else
      content_tag :li, class: "#{init_tab(form, show_summary)}" do
        concat(
          link_to("#tab_#{form.section_name}", class: 'non-group') do
            concat(t(form.unique_id, :default => form.name))
          end
        )
      end
    end
  end

  def build_group_tabs(forms)
    group_id = "group_" + forms[0].form_group_name.gsub(" ", "").gsub("/", "")
    content_tag :ul , class: 'sub', id: group_id do
      for form in forms
        concat(content_tag(:li,
          link_to("#tab_#{form.section_name}") do
            concat(t(form.unique_id, :default => form.name))
          end, class: "#{form.is_first_tab ? 'current': ''}"
        ))
      end
    end
  end

  def init_tab(form, show_summary)
    if show_summary && form.section_name == 'mrm_summary_page' || form.is_first_tab
      "current"
    else
      ""
    end
  end

  def display_help_text_on_view?(formObject, form_section)
    return false unless form_section.display_help_text_view
    field = form_section.fields.first
    if field
      if field.type == Field::SUBFORM
        #If subform is the only field in the form and the first, check is is empty.
        if form_section.form_group_name.present? and form_section.form_group_name == "Violations"
          return formObject[form_section.form_group_name.downcase][field.name].blank?
        else
          return formObject[field.name].blank?
        end
      else
        #There is no straightforward way to know that "Audio and Photo" or "Other Documents" section are empties
        #So, the verification rely on the hardcoded attributes "other_documents", "recorded_audio" and "current_photo_key".

        #assumed we are on "Other Documents" section because the first field is DOCUMENT_UPLOAD_BOX
        if field.type == Field::DOCUMENT_UPLOAD_BOX
          return formObject["other_documents"].blank?
        elsif field.type == Field::PHOTO_UPLOAD_BOX
          #assumed we are on "Audio and Photo" because the first field is PHOTO_UPLOAD_BOX
          blank = formObject["current_photo_key"].blank?
          #assumed the section has two fields and the last one is AUDIO_UPLOAD_BOX.
          f_last = form_section.fields.last
          if f_last.type == Field::AUDIO_UPLOAD_BOX
            blank = blank && formObject["recorded_audio"].blank?
          end
          return blank
        end
      end
    end
    #If there is no field in the section, assumed as invalid section, section should have at least one field.
    false
  end

end
