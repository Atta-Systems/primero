default_locale = nil
yaml_file = Rails.root.join("config", "locales.yml")
locale_settings = YAML::load(File.open(yaml_file))[Rails.env] if File.exists?(yaml_file)

if ActiveRecord::Base.connection.table_exists? :system_settings
  default_locale = ActiveRecord::Base.connection.select_all("SELECT default_locale FROM system_settings LIMIT 1")
                                       .rows
                                       .flatten
                                       .first
end

if locale_settings.present?
  default_locale ||= locale_settings[:default_locale] if locale_settings[:default_locale].present?
  I18n.available_locales = locale_settings[:locales].present? ? locale_settings[:locales] : Primero::Application::LOCALES
else
  default_locale ||= Primero::Application::LOCALE_ENGLISH
  I18n.available_locales = Primero::Application::LOCALES
end

I18n.default_locale = default_locale || Primero::Application::LOCALE_ENGLISH
