protection_concern_fields = [
  Field.new({"name" => "protection_status",
             "type" => "select_box",
             "option_strings_text_all" => "Unaccompanied\nSeparated",
             "display_name_all" => "Protection Status"
            }),
  Field.new({"name" => "urgent_protection_concern",
             "type" => "radio_button",
             "display_name_all" => "Urgent Protection Concern?",
             "option_strings_text_all" => "Yes\nNo",
            }),
  Field.new({"name" => "displacement_status",
             "type" =>"select_box" ,
             "display_name_all" => "Current Displacement Status",
             "option_strings_text_all" => 
                          ["Resident",
                           "IDP",
                           "Refugee",
                           "Stateless Person",
                           "Returnee",
                           "Foreign National",
                           "Asylum Seeker"].join("\n")
            }),
  Field.new({"name" => "unaccompanied_separated_status",
             "type" =>"check_boxes" ,
             "display_name_all" => "Is the client an Unaccompanied Minor, Separated Child, or Other Vulnerable Child?",
             "option_strings_text_all" => 
                          ["No",
                           "Unaccompanied Minor",
                           "Separated Child",
                           "Other Vulnerable Child"].join("\n")
            }),  
  Field.new({"name" => "disability_type",
             "type" =>"select_box" ,
             "display_name_all" => "Disability Type",
             "option_strings_text_all" => 
                          ["Mental Disability",
                           "Physical Disability",
                           "Both"].join("\n")
            })
]

FormSection.create_or_update_form_section({
  :unique_id => "protection_concern",
  :parent_form=>"case",
  "visible" => true,
  :order_form_group => 30,
  :order => 20,
  :order_subform => 0,
  :form_group_name => "Identification / Registration",
  :fields => protection_concern_fields,
  :perm_visible => true,
  "editable" => true,
  "name_all" => "Protection Concerns",
  "description_all" => "Protection concerns"
})