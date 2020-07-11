# frozen_string_literal: true

# The central Primero model object that represents an individual's case.
# In spite of the name, this will represent adult cases as well.
class Child < ApplicationRecord
  self.table_name = 'cases'

  CHILD_PREFERENCE_MAX = 3
  RISK_LEVEL_HIGH = 'high'
  RISK_LEVEL_NONE = 'none'

  class << self
    def parent_form
      'case'
    end

    def model_name_for_messages
      'case'
    end
  end

  def locale_prefix
    'case'
  end

  # This module updates photo_keys with the before_save callback and needs to
  # run before the before_save callback in Historical to make the history
  include Record
  include Searchable
  include Historical
  include BIADerivedFields
  include CaseDerivedFields
  include UNHCRMapping
  include Ownable
  include AutoPopulatable
  include Workflow
  include Serviceable
  include Flaggable
  include Transitionable
  include Reopenable
  include Approvable
  include Alertable
  include Matchable
  include Attachable
  include Noteable

  # include Importable #TODO: Refactor with Imports and Exports

  store_accessor(
    :data,
    :case_id, :case_id_code, :case_id_display,
    :nickname, :name, :protection_concerns, :consent_for_tracing, :hidden_name,
    :name_first, :name_middle, :name_last, :name_nickname, :name_other,
    :registration_date, :age, :estimated, :date_of_birth, :sex, :address_last,
    :reunited, :reunited_message, :investigated, :verified, # TODO: These are RapidFTR attributes and should be removed
    :risk_level, :date_case_plan, :case_plan_due_date, :date_case_plan_initiated,
    :date_closure,
    :system_generated_followup,
    :assessment_due_date, :assessment_requested_on,
    :followup_subform_section, :protection_concern_detail_subform_section,
    :disclosure_other_orgs,
    :ration_card_no, :icrc_ref_no, :unhcr_id_no, :unhcr_individual_no, :un_no, :other_agency_id,
    :survivor_code_no, :national_id_no, :other_id_no, :biometrics_id, :family_count_no, :dss_id, :camp_id, :cpims_id,
    :tent_number, :nfi_distribution_id,
    :nationality, :ethnicity, :religion, :language, :sub_ethnicity_1, :sub_ethnicity_2, :country_of_origin,
    :displacement_status, :marital_status, :disability_type, :incident_details,
    :duplicate, :location_current, :tracing_status, :name_caregiver,
    :urgent_protection_concern, :child_preferences_section, :family_details_section
  )

  has_many :incidents
  belongs_to :matched_tracing_request, class_name: 'TracingRequest', optional: true

  has_many :duplicates, class_name: 'Child', foreign_key: 'duplicate_case_id'
  belongs_to :duplicate_of, class_name: 'Child', foreign_key: 'duplicate_case_id', optional: true

  scope :by_date_of_birth, -> { where.not('data @> ?', { date_of_birth: nil }.to_json) }

  def self.quicksearch_fields
    # The fields family_count_no and dss_id are hacked in only because of Bangladesh
    # The fields camp_id, tent_number and nfi_distribution_id are hacked in only because of Iraq
    %w[ unique_identifier short_id case_id_display name name_nickname name_other
        ration_card_no icrc_ref_no rc_id_no unhcr_id_no unhcr_individual_no un_no
        other_agency_id survivor_code_no national_id_no other_id_no biometrics_id
        family_count_no dss_id camp_id tent_number nfi_distribution_id ]
  end

  def self.summary_field_names
    common_summary_fields + %w[
      case_id_display name survivor_code_no age sex registration_date
      hidden_name workflow case_status_reopened
    ]
  end

  def self.alert_count_self(current_user_name)
    records_owned_by = open_enabled_records.owned_by(current_user_name)
    records_referred_users =
      open_enabled_records.select { |record| record.referred_users.include?(current_user_name) }
    (records_referred_users + records_owned_by).uniq.count
  end

  def self.child_matching_field_names
    MatchingConfiguration.matchable_fields('case', false).pluck(:name) | MatchingConfiguration::DEFAULT_CHILD_FIELDS
  end

  def self.family_matching_field_names
    MatchingConfiguration.matchable_fields('case', true).pluck(:name) | MatchingConfiguration::DEFAULT_INQUIRER_FIELDS
  end

  searchable do
    extend Matchable::Searchable
    Child.child_matching_field_names.each { |f| configure_for_matching(f) }
    Child.family_matching_field_names.each { |f| configure_for_matching_from_subform('family_details_section', f) }

    quicksearch_fields.each do |f|
      text(f) { data[f] }
    end

    %w[registration_date date_case_plan_initiated assessment_requested_on date_closure].each { |f| date(f) }
    boolean :estimated
    integer :day_of_birth
    integer :age

    string :status, as: 'status_sci'
    string :risk_level, as: 'risk_level_sci' do
      risk_level.present? ? risk_level : RISK_LEVEL_NONE
    end
    string :sex, as: 'sex_sci'
    string :national_id_no, as: 'national_id_no_sci'
    string :protection_concerns, multiple: true
    boolean :urgent_protection_concern, as: 'urgent_protection_concern_b'
    boolean :consent_for_tracing

    date :assessment_due_dates, multiple: true do
      Tasks::AssessmentTask.from_case(self).map(&:due_date)
    end

    date :case_plan_due_dates, multiple: true do
      Tasks::CasePlanTask.from_case(self).map(&:due_date)
    end

    date :followup_due_dates, multiple: true do
      Tasks::FollowUpTask.from_case(self).map(&:due_date)
    end
  end

  validate :validate_date_of_birth
  validate :validate_registration_date
  validate :validate_child_wishes

  before_save :sync_protection_concerns
  before_save :auto_populate_name
  before_create :hide_name

  alias super_defaults defaults
  def defaults
    super_defaults
    self.registration_date ||= Date.today
    self.notes_section ||= []
  end

  # TODO: Delete after matching refactor
  def subform_match_values(field)
    family_detail_values(field)
  end

  # TODO: Delete after matching refactor
  def family_detail_values(field)
    family_details_section&.map { |fds| fds[field] }&.compact&.uniq&.join(' ')
  end

  def self.report_filters
    [
      { 'attribute' => 'status', 'value' => [STATUS_OPEN] },
      { 'attribute' => 'record_state', 'value' => ['true'] }
    ]
  end

  # TODO: does this need reporting location???
  # TODO: does this need the reporting_location_config field key
  # TODO: refactor with nested
  def self.minimum_reportable_fields
    {
      'boolean' => ['record_state'],
      'string' => %w[status sex risk_level owned_by_agency_id owned_by workflow workflow_status risk_level],
      'multistring' => %w[associated_user_names owned_by_groups],
      'date' => ['registration_date'],
      'integer' => ['age'],
      'location' => %w[owned_by_location location_current]
    }
  end

  def self.nested_reportable_types
    [ReportableProtectionConcern, ReportableService, ReportableFollowUp]
  end

  def self.by_date_of_birth_range(start_date, end_date)
    return [] unless start_date.is_a?(Date) && end_date.is_a?(Date)

    start_yday = normal_yday(start_date)
    end_yday = normal_yday(end_date)
    Child.search do
      with(:day_of_birth, start_yday..end_yday)
    end.results
  end

  def validate_date_of_birth
    if date_of_birth.present? && (!date_of_birth.is_a?(Date) || date_of_birth.year > Date.today.year)
      errors.add(:date_of_birth, I18n.t('errors.models.child.date_of_birth'))
      false
    else
      true
    end
  end

  def validate_registration_date
    if registration_date.present? && (!registration_date.is_a?(Date) || registration_date.year > Date.today.year)
      errors.add(:registration_date, I18n.t('messages.enter_valid_date'))
      false
    else
      true
    end
  end

  def validate_child_wishes
    return true if child_preferences_section.nil? || child_preferences_section.size <= CHILD_PREFERENCE_MAX

    errors.add(
      :child_preferences_section,
      I18n.t('errors.models.child.wishes_preferences_count', preferences_count: CHILD_PREFERENCE_MAX)
    )
  end

  def to_s
    if name.present?
      "#{name} (#{unique_identifier})"
    else
      unique_identifier
    end
  end

  def auto_populate_name
    # This 2 step process is necessary because you don't want to overwrite self.name if auto_populate is off
    a_name = auto_populate('name')
    self.name = a_name if a_name.present?
  end

  def hide_name
    self.hidden_name = true if module_id == PrimeroModule::GBV
  end

  def set_instance_id
    system_settings = SystemSettings.current
    self.case_id ||= unique_identifier
    self.case_id_code ||= auto_populate('case_id_code', system_settings)
    self.case_id_display ||= create_case_id_display(system_settings)
  end

  def create_case_id_code(system_settings)
    separator = system_settings&.case_code_separator.present? ? system_settings.case_code_separator : ''
    id_code_parts = []
    if system_settings.present? && system_settings.case_code_format.present?
      system_settings.case_code_format.each { |cf| id_code_parts << PropertyEvaluator.evaluate(self, cf) }
    end
    id_code_parts.reject(&:blank?).join(separator)
  end

  def create_case_id_display(system_settings)
    [case_id_code, short_id].compact.join(auto_populate_separator('case_id_code', system_settings))
  end

  # TODO: Delete after matching refactor
  def family(relation = nil)
    result = family_details_section || []
    if relation.present?
      result = result.select do |member|
        member['relation'] == relation
      end
    end
    result
  end

  # TODO: Delete after matching refactor?
  def fathers_name
    family('father').first.try(:[], 'relation_name')
  end

  # TODO: Delete after matching refactor?
  def mothers_name
    family('mother').first.try(:[], 'relation_name')
  end

  # TODO: Delete after matching refactor?
  def caregivers_name
    data['name_caregiver'] || family.select { |fd| fd['relation_is_caregiver'] }.first.try(:[], 'relation_name')
  end

  def day_of_birth
    return nil unless date_of_birth.is_a? Date

    Child.normal_yday(date_of_birth)
  end

  def self.normal_yday(date)
    yday = date.yday
    yday -= 1 if date.leap? && (yday >= 60)
    yday
  end

  def calculated_age
    return nil unless date_of_birth.present? && date_of_birth.is_a?(Date)

    now = Date.current
    born_later_this_month = (now.month == date_of_birth.month) && (now.day >= date_of_birth.day)
    born_later_this_year = now.month > date_of_birth.month
    offset = born_later_this_month || born_later_this_year ? 0 : 1
    now.year - date_of_birth.year - offset
  end

  def sync_protection_concerns
    protection_concerns = self.protection_concerns || []
    from_subforms = protection_concern_detail_subform_section&.map { |pc| pc['protection_concern_type'] }&.compact || []
    self.protection_concerns = (protection_concerns + from_subforms).uniq
  end

  def mark_as_duplicate(parent_id)
    self.duplicate = true
    self.duplicate_case_id = parent_id
  end

  # TODO: Matching methods. Refactor!!!!

  def match_to_trace(tracing_request, trace)
    self.matched_tracing_request_id = tracing_request.id
    self.matched_trace_id = trace['unique_id']
  end

  def matched_to_trace?(tracing_request, trace)
    matched_tracing_request_id.present? && matched_trace_id.present? &&
      (matched_trace_id == trace['unique_id']) && (matched_tracing_request_id == tracing_request.id)
  end

  def matching_tracing_requests(case_fields = {})
    matching_criteria = match_criteria(data, case_fields)
    match_result = Child.find_match_records(matching_criteria, TracingRequest, nil)
    PotentialMatch.matches_from_search(match_result) do |tr_id, score, average_score|
      tracing_request = TracingRequest.find_by(id: tr_id)
      traces = tracing_request.try(:traces) || []
      traces.map do |trace|
        PotentialMatch.build_potential_match(self, tracing_request, score, average_score, trace['unique_id'])
      end
    end.flatten
  end

  alias inherited_match_criteria match_criteria
  def match_criteria(match_request = nil, case_fields = nil)
    match_criteria = inherited_match_criteria(match_request, case_fields)
    match_criteria_subform = {}
    Child.subform_matchable_fields(case_fields).each do |field|
      match_values = []
      match_field = nil
      family.map do |member|
        match_field, match_value = Child.match_multi_criteria(field, member)
        match_values += match_value
      end
      match_criteria_subform[:"#{match_field}"] = match_values if match_values.present?
    end
    match_criteria.merge(match_criteria_subform) { |_key, v1, v2| v1 + v2 }.compact
  end

  def display_id
    case_id_display
  end
end
