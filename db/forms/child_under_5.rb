child_under_5_fields = [
  Field.new({"name" => "date_child_found",
             "type" => "date_field",
             "display_name_all" => "Date child was found"
            }),
  Field.new({"name" => "location_child_found",
             "type" => "text_field",
             "display_name_all" => "Exact location where child was found"
            }),
  Field.new({"name" => "address_child_found",
             "type" => "text_field",
             "display_name_all" => "Found in Village/Area/Physical Address"
            }),
  Field.new({"name" => "found_child_details",
             "type" => "text_field",
             "display_name_all" => "Please describe in details how the child was found or taken in the family children's center"
            }),
  Field.new({"name" => "found_child_people_was_with_location",
             "type" => "text_field",
             "display_name_all" => "Where are the people who were part of the group that was displaced at the same time?"
            }),
  Field.new({"name" => "found_child_people_was_with_address",
             "type" => "text_field",
             "display_name_all" => "Village/Area/Physical Address"
            }),
  Field.new({"name" => "child_finder",
             "type" => "text_field",
             "display_name_all" => "Name of person who gave the child to the family/children's center?"
            }),
  Field.new({"name" => "relationship_child_finder",
             "type" => "text_field",
             "display_name_all" => "What is this person's relationship to the child?"
            }),
  Field.new({"name" => "child_finder_location",
             "type" => "text_field",
             "display_name_all" => "Address"
            }),
  Field.new({"name" => "child_finder_address",
             "type" => "text_field",
             "display_name_all" => "Person's Village/Area/Physical Address"
            }),
  Field.new({"name" => "child_finder_notes",
             "type" => "text_field",
             "display_name_all" => "If that person's address is not known, how could we find him or her and/or provide name(s) and address(es) who may know the person who found the child?"
            }),
  Field.new({"name" => "child_belongings",
             "type" => "select_box",
             "display_name_all" => "Are there any clothes and belongings the child was found with?",
             "option_strings_text_all" => "Yes\nNo",
             }),
  Field.new({"name" => "child_belongings_details",
             "type" => "text_field",
             "display_name_all" => "Please list and describe (including medals, bracelets, hair ties, etc.)"
            }),
  Field.new({"name" => "child_stories_songs_words",
             "type" => "text_field",
             "display_name_all" => "Please write down any stories, songs, words, most often repeated by the child"
            }),
  Field.new({"name" => "child_accent_details",
             "type" => "text_field",
             "display_name_all" => "If the child speaks with an accent and if the family separation has been short (few months), from what region do you think the child comes from?"
            }),
  Field.new({"name" => "child_specific_behavior",
             "type" => "text_field",
             "display_name_all" => "Please write down any behavior specific to the child that may help a parent identify him/her later on such as child's games, and main interests or specific things he/she likes to do"
            }),
]

FormSection.create_or_update_form_section({
  :unique_id=>"child_under_5",
  "visible"=>true,
  :order=> 7,  
  "editable"=>true,
  :fields => child_under_5_fields,
  :perm_visible => true, 
  "name_all" => "Child Under 5",
  "description_all" => "Child Under 5"
})