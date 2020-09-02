# frozen_string_literal: true

json.data do
  json.merge! FieldI18nService.fill_keys(['welcome_email_text_i18n'], @system_setting.attributes.except('id', 'approvals_labels_i18n'))
  json.reporting_location_config current_user.role.reporting_location_config
  json.approvals_labels FieldI18nService.to_localized_values(@system_setting.approvals_labels_i18n)
  if @agencies.present?
    json.agencies do
      json.array! @agencies do |agency|
        json.id agency.id
        json.unique_id agency.unique_id
        json.name agency.name
        json.services agency.services
        if agency.logo_enabled && agency.logo_full.attached?
          json.logo_full = rails_blob_path(agency.logo_full, only_path: true)
        end
        if agency.logo_enabled && agency.logo_icon.attached?
          json.logo_icon = rails_blob_path(agency.logo_icon, only_path: true)
        end
        json.disabled agency.disabled
      end
    end
  end
  if @primero_modules.present?
    json.modules do
      json.array! @primero_modules do |primero_module|
        json.id primero_module.id
        json.unique_id primero_module.unique_id
        json.name primero_module.name
        json.associated_record_types primero_module.associated_record_types
        json.options primero_module.module_options
        # For now only CP case is supported, but the structure can be extended
        if primero_module.unique_id == PrimeroModule::CP
          json.workflows do
            if primero_module.workflow_status_indicator
              ['case'].each do |record_type|
                record_class = Record.model_from_name(record_type)
                json.set! record_type do
                  json.merge! record_class.workflow_statuses([primero_module] )
                end
              end
            end
          end
        end
      end
    end
  end
end.compact!
