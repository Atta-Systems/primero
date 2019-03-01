class Lookup < ActiveRecord::Base

  include Memoizable
  include LocalizableJsonProperty

  localize_properties :name
  localize_properties :lookup_values

  #TODO - seems to be causing trouble
  #TODO - remove  (No longer using in lookup seeds / config)
  DEFAULT_UNKNOWN_ID_TO_NIL = 'default_convert_unknown_id_to_nil'

  validate :validate_name_in_english
  validate :validate_values_keys_match

  after_initialize :generate_unique_id

  before_validation :generate_values_keys
  before_validation :sync_lookup_values
  before_destroy :check_is_being_used

  class << self
    alias :old_all :all
    alias :get_all :all

    def all
      old_all
    end
    # memoize_in_prod :all

    def values(lookup_id, lookups = nil, opts={})
      locale = opts[:locale].presence || I18n.locale
      if lookups.present?
        lookup = lookups.find {|lkp| lkp.unique_id == lookup_id}
      else
        lookup = Lookup.find_by(unique_id: lookup_id)
      end
      lookup.present? ? (lookup.lookup_values(locale) || []) : []
    end
    # memoize_in_prod :values

    def values_for_select(lookup_id, lookups = nil, opts={})
      opts[:locale] = I18n.locale
      self.values(lookup_id, lookups, opts).map{|option| [option['display_text'], option['id']]}
    end

    def form_group_name(form_group_id, parent_form, module_name, opts={})
      lookup_ids = module_name.present? ? ["lookup-form-group-#{module_name.downcase}-#{parent_form}"] : form_group_lookup_mapping(parent_form)
      return '' if lookup_ids.blank?
      locale = opts[:locale].presence || I18n.locale
      lookups = Lookup.where(unique_id: lookup_ids)
      lookups.present? ? lookups.map{|l| l.lookup_values(locale)}.flatten.select{|v| v['id'] == form_group_id}.try('first').try(:[], 'display_text') : ''
    end
    # memoize_in_prod :form_group_name

    def add_form_group(form_group_id, form_group_description, parent_form, module_name, opts={})
      return if parent_form.blank?
      lookup_ids = module_name.present? ? ["lookup-form-group-#{module_name.downcase}-#{parent_form}"] : form_group_lookup_mapping(parent_form)
      return if lookup_ids.blank?

      lookup_ids.each do |lkp_id|
        lookup = Lookup.find_by(unique_id: lkp_id)
        if lookup.present? && lookup.lookup_values_en.map{|v| v['id']}.exclude?(form_group_id)
          new_values = lookup.lookup_values_en + [{id: form_group_id, display_text: form_group_description}.with_indifferent_access]
          lookup.lookup_values_en = new_values
          lookup.save
        end
      end
    end

    def display_value(lookup_id, option_id, lookups = nil, opts={})
      opts[:locale] = I18n.locale
      Lookup.values(lookup_id, lookups, opts).find{|l| l["id"] == option_id}.try(:[], 'display_text')
    end

    def get_location_types
      find_by(unique_id: 'lookup-location-type')
    end
    # memoize_in_prod :get_location_types

    def import_translations(lookups_hash={}, locale)
      if locale.present? && Primero::Application::locales.include?(locale.try(:to_sym))
        lookups_hash.each do |key, value|
          if key.present?
            lookup = Lookup.find_by(unique_id: key)
            if lookup.present?
              lookup.update_translations(value, locale)
              Rails.logger.info "Updating Lookup translation: Lookup [#{lookup.id}] locale [#{locale}]"
              lookup.save!
            else
              Rails.logger.error "Error importing translations: Lookup for ID [#{key}] not found"
            end
          else
            Rails.logger.error "Error importing translations: Lookup ID not present"
          end
        end
      else
        Rails.logger.error "Error importing translations: locale not present"
      end
    end

    private

    def form_group_lookup_mapping(parent_form)
      lookup_ids = []
      case parent_form
        when 'case'
          lookup_ids = ['lookup-form-group-cp-case', 'lookup-form-group-gbv-case']
        when 'tracing_request'
          lookup_ids = ['lookup-form-group-cp-tracing-request']
        when 'incident'
          lookup_ids = ['lookup-form-group-cp-incident', 'lookup-form-group-gbv-incident']
        else
          #Nothing to do here
      end
      lookup_ids
    end
  end

  def localized_property_hash(locale = Primero::Application::BASE_LANGUAGE)
    lh = localized_hash(locale)
    lvh = {}
    self["lookup_values_#{locale}"].try(:each) {|lv| lvh[lv['id']] = lv['display_text']}
    lh['lookup_values'] = lvh
    lh
  end

  def sanitize_lookup_values
    self.lookup_values.reject!(&:blank?) if self.lookup_values
  end

  def validate_values_keys_match
    default_ids = self.lookup_values_en.try(:map){|lv| lv['id']}
    if default_ids.present?
      Primero::Application::locales.each do |locale|
        next if locale == Primero::Application::BASE_LANGUAGE || self.send("lookup_values_#{locale}").blank?
        locale_ids = self.send("lookup_values_#{locale}").try(:map){|lv| lv['id']}
        return errors.add(:lookup_values, I18n.t("errors.models.field.translated_options_do_not_match")) if ((default_ids - locale_ids).present? || (locale_ids - default_ids).present?)
      end
    end
    true
  end

  def clear_all_values
    Primero::Application::locales.each do |locale|
      self.send("lookup_values_#{locale}=", nil)
    end
  end

  def is_being_used?
    Field.where(option_strings_source: "lookup #{self.id}").size.positive?
  end

  # TODO keep?
  def label
    self.name.gsub(' ', '')
  end

  # TODO keep?
  def valid?(context = :default)
    self.name = self.name.try(:titleize)
    sanitize_lookup_values
    super(context)
  end

  def generate_unique_id
    if self.name_en.present? && self.unique_id.blank?
      code = UUIDTools::UUID.random_create.to_s.last(7)
      self.unique_id = "lookup-#{self.name_en}-#{code}".parameterize.dasherize
    end
  end

  def check_is_being_used
    if self.is_being_used?
      errors.add(:name, I18n.t("errors.models.lookup.being_used"))
      throw(:abort)
    end
  end

  private

  def validate_name_in_english
    return true if self.name_en.present?
    errors.add(:name, 'errors.models.lookup.name_present')
    return false
  end





  def generate_values_keys
    if self.lookup_values.present?
      self.lookup_values.each_with_index do |option, i|
        new_option_id = nil
        option_id_updated = false
        if option.is_a?(Hash)
          if option['id'].blank? && option['display_text'].present?
            #TODO - examine if this is proper
            #TODO - Using a random number at the end screws things up when exporting the lookup.yml to load into Transifex
            new_option_id = option['display_text'].parameterize.underscore + '_' + rand.to_s[2..6]
            option_id_updated = true
          elsif option['id'] == DEFAULT_UNKNOWN_ID_TO_NIL
            #TODO - seems to be causing trouble
            #TODO - remove  (No longer using in lookup seeds / config)
            new_option_id = nil
            option_id_updated = true
          end
        end
        if option_id_updated
          Primero::Application::locales.each{|locale|
            lv = self.send("lookup_values_#{locale}")
            lv[i]['id'] = new_option_id if lv.present?
          }
        end
      end
    end
  end

  def sync_lookup_values
    #Do not create any new lookup values that do not have a matching lookup value in the default language
    default_ids = self.send("lookup_values_en").try(:map){|lv| lv['id']}
    if default_ids.present?
      Primero::Application::locales.each do |locale|
        next if locale == Primero::Application::BASE_LANGUAGE
        self.send("lookup_values_#{locale}").try(:reject!){|lv| default_ids.exclude?(lv['id'])}
      end
    end
  end

  def update_translations(lookup_hash={}, locale)
    if locale.present? && Primero::Application::locales.include?(locale)
      lookup_hash.each do |key, value|
        if key == 'lookup_values'
          update_lookup_values_translations(value, locale)
        else
          self.send("#{key}_#{locale}=", value)
        end
      end
    else
      Rails.logger.error "Lookup translation not updated: Invalid locale [#{locale}]"
    end
  end


  def update_lookup_values_translations(lookup_values_hash, locale)
    options = (self.send("lookup_values_#{locale}").present? ? self.send("lookup_values_#{locale}") : [])
    lookup_values_hash.each do |key, value|
      lookup_value = options.try(:find){|lv| lv['id'] == key}
      if lookup_value.present?
        lookup_value['display_text'] = value
      else
        options << {'id' => key, 'display_text' => value}
      end
    end
    self.send("lookup_values_#{locale}=", options)
  end
end
