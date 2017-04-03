consent_for_referrals_fields = [
  Field.new({"name" => "consent_release_separator",
             "type" => "separator",
             "display_name_all" => "Consent to Release Information by Referral Type",
            }),
  Field.new({"name" => "consent_to_share_info_by_security",
             "type" => "radio_button",
             "display_name_all" => "Consent to Release Information to Security Services",
             "option_strings_source" => "lookup lookup-yes-no"
            }),
  Field.new({"name" => "consent_to_share_security_organization",
             "type" => "text_field",
             "display_name_all" => "Specify Security Name, Facility or Agency/Organization as applicable"
            }),
  Field.new({"name" => "consent_to_share_info_by_psychosocial",
             "type" => "radio_button",
             "display_name_all" => "Consent to Release Information to Psychosocial Services",
             "option_strings_source" => "lookup lookup-yes-no"
            }),
  Field.new({"name" => "consent_to_share_psychosocial_organization",
             "type" => "text_field",
             "display_name_all" => "Specify Psychosocial Name, Facility or Agency/Organization as applicable"
            }),
  Field.new({"name" => "consent_to_share_info_by_health",
             "type" => "radio_button",
             "display_name_all" => "Consent to Release Information to Health/Medical Services",
             "option_strings_source" => "lookup lookup-yes-no"
            }),
  Field.new({"name" => "consent_to_share_health_organization",
             "type" => "text_field",
             "display_name_all" => "Specify Health/Medical Name, Facility or Agency/Organization as applicable"
            }),
  Field.new({"name" => "consent_to_share_info_by_safehouse",
             "type" => "radio_button",
             "display_name_all" => "Consent to Release Information to Safe House/Shelter",
             "option_strings_source" => "lookup lookup-yes-no"
            }),
  Field.new({"name" => "consent_to_share_safehouse_organization",
             "type" => "text_field",
             "display_name_all" => "Specify Safe House/Shelter Name, Facility or Agency/Organization as applicable"
            }),
  Field.new({"name" => "consent_to_share_info_by_legal",
             "type" => "radio_button",
             "display_name_all" => "Consent to Release Information to Legal Assistance Services",
             "option_strings_source" => "lookup lookup-yes-no"
            }),
  Field.new({"name" => "consent_to_share_legal_organization",
             "type" => "text_field",
             "display_name_all" => "Specify Legal Assistance Name, Facility or Agency/Organization as applicable"
            }),
  Field.new({"name" => "consent_to_share_info_by_protection",
             "type" => "radio_button",
             "display_name_all" => "Consent to Release Information to Protection Services",
             "option_strings_source" => "lookup lookup-yes-no"
            }),
  Field.new({"name" => "consent_to_share_protection_organization",
             "type" => "text_field",
             "display_name_all" => "Specify Protection Services Name, Facility or Agency/Organization as applicable"
            }),
  Field.new({"name" => "consent_to_share_info_by_livelihoods",
             "type" => "radio_button",
             "display_name_all" => "Consent to Release Information to Livelihoods Services",
             "option_strings_source" => "lookup lookup-yes-no"
            }),
  Field.new({"name" => "consent_to_share_livelihoods_organization",
             "type" => "text_field",
             "display_name_all" => "Specify Livelihoods Services Name, Facility or Agency/Organization as applicable"
            }),
  Field.new({"name" => "consent_to_share_info_by_other",
             "type" => "radio_button",
             "display_name_all" => "Consent to Release Information to Other Services",
             "option_strings_source" => "lookup lookup-yes-no"
            }),
  Field.new({"name" => "consent_to_share_info_by_other_details",
             "type" => "text_field",
             "display_name_all" => "If other services, please specify service, name and agency"
            })
]

FormSection.create_or_update_form_section({
  :unique_id=>"consent_for_referrals",
  :parent_form=>"case",
  "visible" => true,
  :order_form_group => 80,
  :order => 10,
  :order_subform => 0,
  :form_group_name => "Consent for Referrals",
  "editable" => true,
  :fields => consent_for_referrals_fields,
  "name_all" => "Consent for Referrals",
  "description_all" => "Consent for Referrals",
})