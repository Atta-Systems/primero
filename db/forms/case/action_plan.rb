gbv_follow_up_subform_fields = [
  Field.new({"name" => "followup_service_type",
             "type" => "select_box",
             "display_name_all" => "Type of service",
             "option_strings_text_all" =>
                           ["Safehouse Service",
                            "Health/Medical Service",
                            "Psychosocial Service",
                            "Police/Other Service",
                            "Legal Assistance Service",
                            "Livelihoods Service",
                            "Child Protection Service",
                            "Family Mediation Service",
                            "Family Reunification Service",
                            "Education Service",
                            "NFI/Clothes/Shoes Service",
                            "Water/Sanitation Service",
                            "Registration Service",
                            "Food Service",
                            "Other Service"].join("\n")
            }),
  Field.new({"name" => "followup_date",
             "type" => "date_field",
             "display_name_all" => "Follow up date"
            }),
  Field.new({"name" => "action_taken_already",
             "type" => "radio_button",
             "display_name_all" => "Has action been taken?",
             "option_strings_text_all" => ["Yes", "No"].join("\n")
            }),
  Field.new({"name" => "action_taken_details",
             "type" => "text_field",
             "display_name_all" => "Details about action taken"
            }),
  Field.new({"name" => "need_follow_up_visit",
             "type" => "radio_button",
             "display_name_all" => "Is there a need for further follow up visits?",
             "option_strings_text_all" => ["Yes", "No"].join("\n")
            }),
  Field.new({"name" => "when_follow_up_visit_should_happen",
             "type" => "date_field",
             "display_name_all" => "If yes, when do you recommend the next visit to take place?"
            }),
  Field.new({"name" => "recommend_case_closed",
             "type" => "radio_button",
             "display_name_all" => "If not, do you recommend that the case be closed?",
             "option_strings_text_all" => ["Yes", "No"].join("\n")
            }),
  Field.new({"name" => "followup_comments",
             "type" => "text_field",
             "display_name_all" => "Comments"
            }),
  Field.new({"name" => "progress_made_towards_goals",
             "type" => "separator",
             "display_name_all" => "Progress made towards GOALS",
             "help_text_all" => "Evaluate Progress Made Towards GOALS agreed on in Survivor Assessment & Case Action Plan"
            }),
  Field.new({"name" => "gbv_assessment_progress_safety",
             "type" => "radio_button",
             "display_name_all" => "Progress towards Safety goals",
             "option_strings_text_all" => "N/A\nin progress\nmet"
            }),
  Field.new({"name" => "gbv_assessment_progress_safety_text",
             "type" => "text_field",
             "display_name_all" => "Explain Progress towards Safety goals"
            }),
  Field.new({"name" => "gbv_assessment_progress_health",
             "type" => "radio_button",
             "display_name_all" => "Progress towards Heath care goals",
             "option_strings_text_all" => "N/A\nin progress\nmet"
            }),
  Field.new({"name" => "gbv_assessment_progress_health_text",
             "type" => "text_field",
             "display_name_all" => "Explain Progress towards Heath care goals"
            }),
  Field.new({"name" => "gbv_assessment_progress_psychosocial",
             "type" => "radio_button",
             "display_name_all" => "Progress towards Psychosocial Support goals",
             "option_strings_text_all" => "N/A\nin progress\nmet"
            }),
  Field.new({"name" => "gbv_assessment_progress_psychosocial_text",
             "type" => "text_field",
             "display_name_all" => "Explain Progress towards Psychosocial Support goals"
            }),
  Field.new({"name" => "gbv_assessment_progress_justice",
             "type" => "radio_button",
             "display_name_all" => "Progress towards Access to Justice goals",
             "option_strings_text_all" => "N/A\nin progress\nmet"
            }),
  Field.new({"name" => "gbv_assessment_progress_justice_text",
             "type" => "text_field",
             "display_name_all" => "Explain Progress towards Access to Justice goals"
            }),
  Field.new({"name" => "gbv_assessment_other_goals_list",
             "type" => "text_field",
             "display_name_all" => "Other goals (list here)"
            }),
  Field.new({"name" => "gbv_assessment_other_goals",
             "type" => "radio_button",
             "display_name_all" => "Progress towards other goals",
             "option_strings_text_all" => "N/A\nin progress\nmet"
            }),
  Field.new({"name" => "gbv_assessment_other_goals_text",
             "type" => "text_field",
             "display_name_all" => "Explain Progress towards other goals"
            })
]

action_plan_subform_fields = [
  Field.new({
    "name" => "action_plan_description",
    "type" => "textarea",
    "display_name_all" => "Describe the action plan to address this need."
  }),
  Field.new({
    "name" => "service_type",
    "type" => "select_box",
    "display_name_all" => "Type of Need",
    "option_strings_text_all" => [
      "Safehouse",
      "Health/Medical",
      "Psycosocial/Counseling",
      "Legal Assistance",
      "Police or Other Type of Security",
      "Livelihoods",
      "Child Protection",
      "Family Mediation",
      "Family Reunification",
      "Education",
      "NFI/Clothes/Shoes",
      "Water/Sanitation",
      "Refugee Registration",
      "Food",
      "Other"
    ].join("\n")
  }),
  Field.new({
    "name" => "service_referral",
    "type" => "select_box",
    "display_name_all" => "Did you refer the client for this service?",
    "option_strings_text_all" => [
      "Referred",
      "No referral, Service provided by your agency",
      "No referral, Services already received from another agency",
      "No referral, Service not applicable",
      "No referral, Declined by survivor",
      "No referral, Service unavailable"
    ].join("\n")
  }),
  Field.new({
    "name" => "service_appointment_date",
    "type" => "date_field",
    "display_name_all" => "Appointment Date"
  }),
  Field.new({
    "name" => "service_appointment_time",
    "type" => "text_field",
    "display_name_all" => "Appointment Time"
  }),
  Field.new({
    "name" => "service_provider",
    "type" => "text_field",
    "display_name_all" => "Service Provider"
  }),
  Field.new({
    "name" => "service_location",
    "type" => "text_field",
    "display_name_all" => "Service Location"
  }),
  Field.new({
    "name" => "service_referral_notes",
    "type" => "text_field",
    "display_name_all" => "Notes"
  })
]

gbv_follow_up_subform_section = FormSection.create_or_update_form_section({
  "visible" => false,
  "is_nested" => true,
  :order_form_group => 60,
  :order => 10,
  :order_subform => 1,
  :unique_id => "gbv_follow_up_subform_section",
  :parent_form=>"case",
  "editable" => true,
  :fields => gbv_follow_up_subform_fields,
  :initial_subforms => 1,
  :perm_visible => false,
  "name_all" => "Nested GBV Follow Up Subform",
  "description_all" => "Nested GBV Follow Up Subform",
  "collapsed_fields" => ["followup_service_type", "followup_date"]
})

action_plan_subform_section = FormSection.create_or_update_form_section({
    "visible"=>false,
    "is_nested"=>true,
    :order_form_group => 60,
    :order => 50,
    :order_subform => 1,
    :unique_id=>"action_plan_subform_section",
    :parent_form=>"case",
    "editable"=>true,
    :fields => action_plan_subform_fields,
    :initial_subforms => 1,
    "name_all" => "Nested Action Plan",
    "description_all" => "Action Plan Subform",
    "collapsed_fields" => ["service_type", "service_appointment_date"]
})

action_plan_fields = [
  Field.new({"name" => "incident_links",
             "type" => "custom",
             "display_name_all" => "Incident Links",
             "custom_template" => "children/incident_links",
             "create_property" => false,
             "editable" => true
            }),
  Field.new({"name" => "action_explanation_header",
             "type" => "separator",
             "display_name_all" => "Action Plan ", #Note the extra trailing space!
             "help_text_all" => "Please add all needs that you identified in the assessment. Use the Add button to add other needs that should be part of the Action Plan."
            }),
  Field.new({"name" => "action_plan_section",
             "type" => "subform", "editable" => true,
             "subform_section_id" => action_plan_subform_section.unique_id,
             "display_name_all" => "Action Plan"
            }),
  Field.new({"name" => "action_follow_up_header",
             "type" => "separator",
             "display_name_all" => "Follow Ups"
            }),
  Field.new({"name" => "gbv_follow_up_subform_section",
             "type" => "subform", "editable" => true,
             "subform_section_id" => gbv_follow_up_subform_section.unique_id,
             "display_name_all" => "Follow Up"
  })
]

FormSection.create_or_update_form_section({
  :unique_id=>"action_plan_form",
  :parent_form=>"case",
  "visible" => true,
  :order_form_group => 60,
  :order => 30,
  :order_subform => 0,
  :form_group_name => "Action Plan",
  "editable" => true,
  :fields => action_plan_fields,
  "name_all" => "Action Plan",
  "description_all" => "Action Plan"
})