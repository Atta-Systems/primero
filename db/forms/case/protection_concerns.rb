protection_concern_fields = [
  Field.new({"name" => "protection_status",
             "type" => "select_box",
             "option_strings_source" => "lookup ProtectionStatus",
             "display_name_all" => "Protection Status"
            }),
  Field.new({"name" => "urgent_protection_concern",
             "type" => "radio_button",
             "display_name_all" => "Urgent Protection Concern?",
             "option_strings_text_all" => "Yes\nNo"
            }),
  Field.new({"name" => "risk_level",
             "type" => "select_box",
             "display_name_all" => "Risk Level",
             "option_strings_source" => "lookup RiskLevel"
            }),
  Field.new({"name" => "system_generated_followup",
             "type" => "tick_box",
             "display_name_all" => "Generate follow up reminders?"
            }),
  Field.new({"name" => "displacement_status",
             "type" =>"select_box" ,
             "display_name_all" => "Displacement Status",
             "option_strings_source" => "lookup DisplacementStatus"
            }),
  Field.new({"name" => "unhcr_protection_code",
             "type" => "text_field",
             "display_name_all" => "UNHCR Protection Code",
             "visible" => false,
             "editable" => false,
             "disabled" => true,
             "help_text_all" => "This field is deprecated in v1.2 and replaced by unchr_needs_code"
            }),
  Field.new({"name" => "protection_concerns",
             "type" => "select_box",
             "multi_select" => true,
             "display_name_all" => "Protection Concerns",
             "required" => false,
             "option_strings_source" => "lookup ProtectionConcerns"
            }),
  Field.new({"name" => "protection_concerns_other",
             "type" => "text_field",
             "display_name_all" => "If Other, please specify"
            }),
  Field.new({"name" => "unhcr_needs_codes",
             "type" => "select_box",
             "multi_select" => true,
             "display_name_all" => "UNHCR Needs Codes",
             "option_strings_source" => "lookup UnhcrNeedsCodes"
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
  "editable" => true,
  "name_all" => "Protection Concerns",
  "description_all" => "Protection concerns"
})