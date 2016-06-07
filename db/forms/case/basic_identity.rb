basic_identity_fields = [
  Field.new({"name" => "case_id",
             "type" => "text_field",
             "editable" => false,
             "display_name_all" => "Long ID",
             "create_property" => false,
             "visible" => false
            }),
  Field.new({"name" => "short_id",
             "type" => "text_field",
             "editable" => false,
             "display_name_all" => "Short ID",
             "create_property" => false,
             "visible" => false
            }),
  Field.new({"name" => "case_id_display",
             "type" => "text_field",
             "editable" => false,
             "display_name_all" => "Case ID",
             "create_property" => true
            }),
  Field.new({"name" => "marked_for_mobile",
             "type" => "tick_box",
             "tick_box_label_all" => "Yes",
             "display_name_all" => "Marked for mobile?",
             "editable" => false,
             "create_property" => false
            }),
  Field.new({"name" => "child_status",
             "type" =>"select_box" ,
             "display_name_all" => "Case Status",
             "option_strings_source" => "lookup CaseStatus"
            }),
  Field.new({"name" => "name",
             "type" => "text_field",
             "display_name_all" => "Full Name",
             "highlight_information" => HighlightInformation.new("highlighted" => true,"order"=>1),
             "required" => false,
             "hidden_text_field" => true
            }),
  Field.new({"name" => "name_first",
             "type" => "text_field",
             "display_name_all" => "First Name",
             "required" => false,
             "hide_on_view_page" => true
            }),
  Field.new({"name" => "name_middle",
             "type" => "text_field",
             "display_name_all" => "Middle Name",
             "hide_on_view_page" => true
            }),
  Field.new({"name" => "name_last",
             "type" => "text_field",
             "display_name_all" => "Surname",
             "required" => false,
             "hide_on_view_page" => true
            }),
  Field.new({"name" => "name_nickname",
             "type" => "text_field",
             "display_name_all" => "Nickname"
            }),
  Field.new({"name" => "name_other",
             "type" => "text_field",
             "display_name_all" => "Other Name"
            }),
  Field.new({"name" => "name_given_post_separation",
             "type" => "radio_button",
             "display_name_all" => "Name(s) given to child after separation?",
             "option_strings_text_all" => "Yes\nNo",
            }),
  Field.new({"name" => "registration_date",
             "type" => "date_field",
             "required" => false,
             "display_name_all" => "Date of Registration or Interview",
             "date_validation" => "not_future_date"
            }),
  Field.new({"name" => "sex",
             "type" => "select_box",
             "option_strings_text_all" => "Male\nFemale",
             "required" => false,
             "display_name_all" => "Sex"
            }),
  Field.new({"name" => "age",
             "type" => "numeric_field",
             "required" => false,
             "display_name_all" => "Age"
            }),
  Field.new({"name" => "date_of_birth",
            "type" => "date_field",
            "required" => false,
            "display_name_all" => "Date of Birth",
            "date_validation" => "not_future_date"
            }),
  Field.new({"name" => "estimated",
             "type" => "tick_box",
             "tick_box_label_all" => "Yes",
             "display_name_all" => "Is the age estimated?",
            }),
  Field.new({"name" => "physical_characteristics",
             "type" => "textarea",
             "display_name_all" => "Distinguishing Physical Characteristics"
            }),
  Field.new({"name" => "ration_card_no",
             "type" => "text_field",
             "display_name_all" => "Ration Card Number"
            }),
  Field.new({"name" => "icrc_ref_no",
             "type" => "text_field",
             "display_name_all" => "ICRC Ref No."
            }),
  Field.new({"name" => "rc_id_no",
             "type" => "text_field",
             "display_name_all" => "RC ID No."
            }),
  Field.new({"name" => "unhcr_id_no",
             "type" => "text_field",
             "display_name_all" => "UNHCR ID"
            }),
  Field.new({"name" => "un_no",
            "type" => "text_field",
            "display_name_all" => "UN Number"
            }),
  Field.new({"name" => "other_agency_id",
            "type" => "text_field",
            "display_name_all" => "Other Agency ID"
            }),
  Field.new({"name" => "other_agency_name",
            "type" => "text_field",
            "display_name_all" => "Other Agency Name"
            }),
  Field.new({"name" => "documents_carried",
             "type" => "textarea",
             "display_name_all" => "List of documents carried by the child"
            }),
  Field.new({"name" => "maritial_status",
             "type" =>"select_box" ,
             "display_name_all" => "Current Civil/Marital Status",
             "option_strings_text_all" =>
                          ["Single",
                           "Married/Cohabitating",
                           "Divorced/Separated",
                           "Widowed"].join("\n")
            }),
  Field.new({"name" => "occupation",
             "type" => "text_field",
             "display_name_all" => "Occupation"
            }),
  Field.new({"name" => "address_current",
             "type" => "textarea",
             "required" => false,
             "display_name_all" => "Current Address"
            }),
  Field.new({"name" => "landmark_current",
             "type" => "text_field",
             "display_name_all" => "Landmark"
            }),
  Field.new({"name" => "location_current",
             "type" =>"select_box",
             "display_name_all" => "Current Location",
             "searchable_select" => true,
             "option_strings_source" => "Location"
            }),
  Field.new({"name" => "address_is_permanent",
             "type" => "tick_box",
             "display_name_all" => "Is this address permanent?"
            }),
  Field.new({"name" => "telephone_current",
             "type" => "text_field",
             "display_name_all" => "Current Telephone"
            })
]

FormSection.create_or_update_form_section({
  :unique_id=>"basic_identity",
  :parent_form=>"case",
  "visible" => true,
  :order_form_group => 30,
  :order => 10,
  :order_subform => 0,
  :form_group_name => "Identification / Registration",
  "editable" => true,
  :fields => basic_identity_fields,
  :is_first_tab => true,
  "name_all" => "Basic Identity",
  "description_all" => "Basic identity information about a separated or unaccompanied child.",
  :mobile_form => true
})
