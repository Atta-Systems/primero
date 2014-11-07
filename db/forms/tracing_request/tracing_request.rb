tracing_request_subform_fields = [
  #TODO make this a link on the show page somehow
  Field.new({"name" => "matched_case_id",
             "type" => "text_field",
             "editable" => false,
             "display_name_all" => "Matched Case ID"
           }),
  Field.new({"name" => "tracing_request_status",
             "type" =>"select_box" ,
             "display_name_all" => "Tracing status",
             "option_strings_text_all" =>
                                 ["Open",
                                  "Tracing in Progress",
                                  "Verified",
                                  "Reunified",
                                  "Closed"].join("\n")
            }),
  Field.new({"name" => "individual_details_section",
             "type" => "separator",
             "display_name_all" => "Individual Details"
            }),
  Field.new({"name" => "name",
             "type" => "text_field",
             "display_name_all" => "Name"
           }),
  Field.new({"name" => "relation_to_inquirer",
             "type" => "select_box",
             "display_name_all" => "How are they related to the inquirer?",
             "option_strings_text_all" =>
                                    ["Son",
                                     "Daughter",
                                     "Niece",
                                     "Nephew",
                                     "Grandchild",
                                     "Brother",
                                     "Sister",
                                     "Other family",
                                     "Other non-family"].join("\n")
            }),
  Field.new({"name" => "relation_child_lived_with_pre_separation",
             "type" => "radio_button",
             "display_name_all" => "Did the child live with the inquirer before separation?",
             "option_strings_text_all" => "Yes\nNo"
            }),
  Field.new({"name" => "name_nickname",
             "type" => "text_field",
             "display_name_all" => "Nickname"
           }),
  Field.new({"name" => "name_other",
             "type" => "text_field",
             "display_name_all" => "Other Name"
           }),
  Field.new({"name" => "sex",
             "type" => "select_box",
             "display_name_all" => "Sex",
             "option_strings_text_all" => "Male\nFemale"
            }),
  Field.new({"name" => "age",
             "type" => "numeric_field",
             "display_name_all" => "Age"
           }),
  Field.new({"name" => "date_of_birth",
             "type" => "date_field",
             "display_name_all" => "Date of Birth"
             }),
  Field.new({"name" => "physical_characteristics",
             "type" => "textarea",
             "display_name_all" => "Distinguishing Physical Characteristics"
            }),
  Field.new({"name" => "inquirer_special_message",
               "type" => "textarea",
               "display_name_all" => "Special Message for the person being sought"
              }),
  Field.new({"name" => "same_separation_details",
             "type" => "tick_box",
             "display_name_all" => "Same separation details as on Inquirer form?"
            }),
  Field.new({"name" => "separation_details_section",
             "type" => "separator",
             "display_name_all" => "Separation Details (if different)"
            }),
  Field.new({"name" => "date_of_separation",
             "type" => "date_field",
             "display_name_all" => "Date of Separation"
            }),
  Field.new({"name" => "separation_cause",
             "type" => "select_box",
             "display_name_all" => "What was the main cause of separation?",
             "option_strings_text_all" =>
                        ["Conflict",
                        "Death",
                        "Family abuse/violence/exploitation",
                        "Lack of access to services/support",
                        "CAAFAG",
                        "Sickness of family member",
                        "Entrusted into the care of an individual",
                        "Arrest and detention",
                        "Abandonment",
                        "Repatriation",
                        "Population movement",
                        "Migration",
                        "Poverty",
                        "Natural disaster",
                        "Divorce/remarriage",
                        "Other (please specify)"].join("\n")
            }),
  Field.new({"name" => "separation_evacuation",
             "type" => "tick_box",
             "display_name_all" => "Did the separation occur in relation to evacuation?"
            }),
  Field.new({"name" => "separation_details",
             "type" => "textarea",
             "display_name_all" => "Circumstances of Separation (please provide details)"
            }),
  Field.new({"name" => "address_separation",
             "type" => "text_field",
             "display_name_all" => "Separation Address (Place)"
            }),
  Field.new({"name" => "location_separation",
             "type" => "select_box",
             "display_name_all" => "Separation Location",
             "searchable_select" => true,
             "option_strings_source" => "Location"
            }),
  Field.new({"name" => "address_last",
             "type" => "textarea",
             "display_name_all" => "Last Address"
            }),
  Field.new({"name" => "landmark_last",
             "type" => "text_field",
             "display_name_all" => "Last Landmark"
            }),
  Field.new({"name" => "location_last",
             "type" =>"select_box" ,
             "display_name_all" => "Last Location",
             "searchable_select" => true,
             "option_strings_source" => "Location"
            }),
  Field.new({"name" => "telephone_last",
             "type" => "text_field",
             "display_name_all" => "Last Telephone"
            }),
  Field.new({"name" => "additional_tracing_info",
             "type" => "textarea",
             "display_name_all" => "Additional info that could help in tracing?"
            })
]

tracing_request_subform_section = FormSection.create_or_update_form_section({
  "visible" => false,
  "is_nested" => true,
  :order_form_group => 10,
  :order => 10,
  :order_subform => 1,
  :unique_id => "tracing_request_subform_section",
  :parent_form=>"tracing_request",
  "editable" => true,
  :fields => tracing_request_subform_fields,
  "name_all" => "Nested Tracing Request Subform",
  "description_all" => "Nested Tracing Request Subform",
  :initial_subforms => 1,
  "collapsed_fields" => ["name", "relation_to_inquirer"],
  :subform_header_links => ["tracing"]
})

tracing_request_tracing_request_fields = [
  Field.new({"name" => "tracing_request_subform_section",
             "type" => "subform",
             "editable" => true,
             "subform_section_id" => tracing_request_subform_section.unique_id,
             "display_name_all" => "Tracing Request"
            })
]

FormSection.create_or_update_form_section({
  :unique_id => "tracing_request_tracing_request",
  :parent_form=>"tracing_request",
  "visible" => true,
  :order_form_group => 30,
  :order => 30,
  :order_subform => 0,
  :form_group_name => "Tracing Request",
  "editable" => true,
  :fields => tracing_request_tracing_request_fields,
  "name_all" => "Tracing Request",
  "description_all" => "Tracing Request"
})
