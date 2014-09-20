other_identity_details_fields = [
  Field.new({"name" => "nationality",
             "type" =>"select_box",
             "multi_select" => true,
             "display_name_all" => "Nationality",
             "option_strings_source" => "lookup Nationality"
            }),
  Field.new({"name" => "place_of_birth",
             "type" => "text_field",
             "display_name_all" => "Place of Birth"
            }),
  Field.new({"name" => "country_of_birth",
             "type" =>"select_box",
             "display_name_all" => "Birth Country",
             "option_strings_source" => "lookup Country"
            }),
  Field.new({"name" => "country_of_origin",
             "type" =>"select_box" ,
             "display_name_all" => "Country of Origin",
             "option_strings_source" => "lookup Country"
            }),
  Field.new({"name" => "address_last",
             "type" => "textarea",
             "display_name_all" => "Last Address"
            }),
  Field.new({"name" => "landmark_last",
             "type" => "text_field",
             "display_name_all" => "Last Landmark"
            }),
  #TODO location picker
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
  Field.new({"name" => "ethnicity",
             "type" =>"select_box",
             "multi_select" => true,
             "display_name_all" => "Ethnicity/Clan/Tribe",
             "option_strings_source" => "lookup Ethnicity"
            }),
  Field.new({"name" => "sub_ethnicity_1",
             "type" =>"select_box",
             "multi_select" => true,
             "display_name_all" => "Sub Ethnicity 1",
             "option_strings_source" => "lookup Ethnicity"
            }),
  Field.new({"name" => "sub_ethnicity_2",
             "type" =>"select_box",
             "multi_select" => true,
             "display_name_all" => "Sub Ethnicity 2",
             "option_strings_source" => "lookup Ethnicity"
            }),
   #TODO configurable by admin
   Field.new({"name" => "language",
             "type" =>"select_box",
             "multi_select" => true,
             "display_name_all" => "Language",
             "option_strings_source" => "lookup Language"
            }),
  Field.new({"name" => "religion",
             "type" =>"select_box",
             "multi_select" => true,
             "display_name_all" => "Religion",
             "option_strings_source" => "lookup Religion"
            })
]

FormSection.create_or_update_form_section({
  :unique_id=>"other_identity_details",
  :parent_form=>"case",
  "visible" => true,
  :order_form_group => 30,
  :order => 30,
  :order_subform => 0,
  :form_group_name => "Identification / Registration",
  "editable" => true,
  :fields => other_identity_details_fields,
  "name_all" => "Other Identity Details",
  "description_all" => "Other Identity Details"
})
