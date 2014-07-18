group_details_section_fields_subform = [
  Field.new({"name" => "group_description",
             "type" => "text_field", 
             "display_name_all" => "Description of the Group of Children"
            }),
  Field.new({"name" => "group_violations",
             "type" => "select_box",
             "display_name_all" => "Violations",
             "option_strings_text_all" =>
                                    ["Option 1",
                                     "Option 2",
                                     "Option 3",
                                     "Option 4"].join("\n")
            }),
  Field.new({"name" => "group_number",
             "type" => "numeric_field", 
             "display_name_all" => "How many children were involved?"
            }),
  Field.new({"name" => "group_gender",
             "type" => "select_box",
             "display_name_all" => "What was the sex of the group of children involved?",
             "option_strings_text_all" =>
                                    ["All Female",
                                     "All Male",
                                     "Mixed",
                                     "Unknown"].join("\n")
            }),
  Field.new({"name" => "group_age_band",
             "type" => "select_box",
             "display_name_all" => "Into which age band did the children fall?",
             "option_strings_text_all" =>
                                    ["<5years",
                                     "≥5<10 years",
                                     "≥10<15 years",
                                     "≥15<18 years",
                                     "Mixed",
                                     "Unknown"].join("\n")
            }),
  Field.new({"name" => "group_ethnicity",
             "type" => "select_box",
             "display_name_all" => "What were the ethnic affiliations of the children involved?",
             "option_strings_text_all" =>
                                    ["Ethnicity 1",
                                     "Ethnicity 2",
                                     "Ethnicity 3",
                                     "Other",
                                     "Mixed", 
                                     "Unknown"].join("\n")
            }),
  Field.new({"name" => "group_nationality",
             "type" => "select_box",
             "display_name_all" => "What was the nationality of the children involved?",
             "option_strings_text_all" =>
                                    ["Nationality 1",
                                     "Nationality 2",
                                     "Nationality 3",
                                     "Other",
                                     "Mixed", 
                                     "Unknown"].join("\n")
            }),
  Field.new({"name" => "group_religion",
             "type" => "select_box",
             "display_name_all" => "What was the religious affiliation of the children involved?",
             "option_strings_text_all" =>
                                    ["Religion 1",
                                     "Religion 2",
                                     "Religion 3",
                                     "Other",
                                     "Mixed", 
                                     "Unknown"].join("\n")
            }),
  Field.new({"name" => "group_displacement_at_time_of_incident",
             "type" => "select_box",
             "display_name_all" => "What was the status of the children involved at the time of the violation ?",
             "option_strings_text_all" =>
                                    ["Community Member",
                                     "IDP",
                                     "Refugee",
                                     "Returnee",
                                     "Mixed",
                                     "Unknown"].join("\n")
            })
]

group_details_section = FormSection.create_or_update_form_section({
  "visible"=>false,
  "is_nested"=>true,
  :order=> 1,
  :unique_id=>"group_details_section",
  :parent_form=>"incident",
  "editable"=>true,
  :fields => group_details_section_fields_subform,
  :perm_enabled => false,
  :perm_visible => false,
  "name_all" => "Nested Group Details",
  "description_all" => "Group Details Subform"
})

group_details_fields = [
  ##Subform##
  Field.new({"name" => "group_details_section",
             "type" => "subform", 
             "editable" => true,
             "subform_section_id" => group_details_section.id,
             "display_name_all" => "Group Details"
            }),
  ##Subform##
]

FormSection.create_or_update_form_section({
  :unique_id => "group_details",
  :parent_form=>"incident",
  "visible" => true,
  :order => 130,
  "editable" => true,
  :fields => group_details_fields,
  :perm_enabled => true,
  "name_all" => "Group Details",
  "description_all" => "Group Details"
})
