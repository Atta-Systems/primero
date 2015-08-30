class Incident < CouchRest::Model::Base
  use_database :incident

  include PrimeroModel
  include Primero::CouchRestRailsBackward

  include Record
  include Ownable
  include Flaggable
  include DocumentUploader
  include GBVDerivedFields

  property :incident_id
  property :description

  def initialize *args
    self['histories'] = []

    super *args
  end

  design do
    view :by_incident_id
    view :by_description,
            :map => "function(doc) {
                if (doc['couchrest-type'] == 'Incident')
               {
                  if (!doc.hasOwnProperty('duplicate') || !doc['duplicate']) {
                    emit(doc['description'], null);
                  }
               }
            }"
  end

  before_save :set_violation_verification_default
  after_save :index_violations
  after_destroy :unindex_violations
  before_save :ensure_violation_categories_exist
  before_save :calculate_gbv_type_of_violence_exclusion

  before_update :clean_incident_date

  def self.quicksearch_fields
    [
      'incident_id', 'incident_code', 'super_incident_name', 'incident_description',
      'monitor_number', 'survivor_code',
      'individual_ids'
    ]
  end
  include Searchable #Needs to be after Ownable

  searchable do
    string :violations, multiple: true do
      self.violation_type_list
    end

    string :verification_status, multiple: true do
      self.violation_verified_list
    end

    string :child_types, multiple: true do
      self.child_types
    end

    string :armed_force_group_names, multiple: true do
      self.armed_force_group_names
    end

    string :perpetrator_sub_categories, multiple: true do
      self.perpetrator_sub_categories
    end

    date :incident_date_derived do
      self.incident_date_derived
    end

  end

  def ensure_violation_categories_exist
    if self.violations.present?
      self.violations.to_hash.compact.each_key do |key|
        self.violation_category = [] if !self.violation_category.present?
        self.violation_category << key if !self.violation_category.include? key
      end
    end
  end

  def self.find_by_incident_id(incident_id)
    by_incident_id(:key => incident_id).first
  end

  #TODO: Keep this?
  def self.search_field
    "description"
  end

  def self.view_by_field_list
    ['created_at', 'description']
  end

  def set_instance_id
    self.incident_id ||= self.unique_identifier
  end

  def create_class_specific_fields(fields)
    self['description'] = fields['description'] || self.description || ''
  end

  def incident_code
    (self.unique_identifier || "").last 7
  end

  def violation_number_of_victims
    self.try(:incident_total_tally_total) || 0
  end

  def violations_subforms
    subforms = []
    subforms = self.violations.to_hash.map{|key, value| value}.flatten if self.violations.present?
    subforms
  end

  def violation_number_of_violations
    self.violations_subforms.size
  end

  def violation_number_of_violations_verified
    number_of_violations_verified = 0
    self.violations_subforms.each do |subform|
      #TODO Do we need I18n for "Verified" string?
      number_of_violations_verified += 1 if subform.try(:verified) == "Verified"
    end
    number_of_violations_verified
  end

  #Returns the 20 latest open incidents.
  #TODO refactoring pagination?
  def self.open_incidents(user)
    #TODO do we need I18n for "Open" string?
    filters = { "record_state" =>{:type => "single", :value => "true"},
                "module_id" => {:type => "single", :value => PrimeroModule::MRM},
                "status" => {:type => "single", :value => "Open"},
              }
    self.list_records(filters=filters, sort={:created_at => :desc}, pagination={ per_page: 20 }, user.managed_user_names).results
  end

  def self.open_gbv_incidents(user)
    #TODO do we need I18n for "Open" string?
    filters = { "record_state" =>{:type => "single", :value => "true"},
                "module_id" => {:type => "single", :value => PrimeroModule::GBV},
                "status" => {:type => "single", :value => "Open"},
              }
    self.list_records(filters=filters, sort={:created_at => :desc}, pagination={ per_page: 20 }, user.managed_user_names).results
  end

  # Each violation type has a field that is used as part of the identification
  # of that violation
  #TODO: This matches up to the collapsed fields on the violation subforms. NOT DRY!!!
  def self.violation_id_fields
    {
      'killing' => 'cause',
      'maiming' => 'cause',
      'recruitment' => 'factors_of_recruitment',
      'sexual_violence' => 'sexual_violence_type',
      'abduction' => 'abduction_purpose',
      'attack_on_schools' => 'site_attack_type',
      'attack_on_hospitals' => 'site_attack_type',
      'denial_humanitarian_access' => 'denial_method',
      'other_violation' => 'violation_other_type'
    }
  end

  def violation_label(violation_type, violation, include_unique_id=false)
    id_fields = self.class.violation_id_fields
    label_id = violation.send(id_fields[violation_type].to_sym)
    label_id_text = (label_id.is_a?(Array) ? label_id.join(', ') : label_id)
    label = label_id.present? ? "#{violation_type.titleize} - #{label_id_text}" : "#{violation_type.titleize}"
    if include_unique_id
      label += " - #{violation['unique_id'].try(:slice, 0, 5)}"
    end
    label
  end

  #TODO - Need rspec test for this
  def violations_list(compact_flag = false, include_unique_id=false)
    violations_list = []
    if self.violations.present?
      self.violations.to_hash.each do |key, value|
        value.each_with_index do |v, i|
          vlabel = violation_label(key, v, include_unique_id)
          # Add an index if compact_flag is false
          violations_list << vlabel
        end
      end
    end

    if compact_flag
      violations_list.uniq! if violations_list.present?
    else
      if violations_list.blank?
        violations_list << "NONE"
      end
    end

    return violations_list
  end

  def violations_list_by_unique_id
    (self.violations || {}).to_hash.inject({}) do |acc, (vtype, vs)|
      acc.merge(vs.inject({}) do |acc2, v|
        acc2.merge({violation_label(vtype, v, true) => v['unique_id']})
      end)
    end
  end

  #TODO - Need rspec test for this
  def violation_type_list
    violations_list = []
    if self.violations.present?
      self.violations.to_hash.each do |key, value|
        if value.present?
          violations_list << key
        end
      end
    end

    return violations_list
  end

  #TODO - Need rspec test for this
  def violation_verified_list
    violation_verified_list = []
    if self.violations.present?
      self.violations.to_hash.each do |key, value|
        value.each do |v|
          violation_verified_list << v.verified if v.verified.present?
        end
      end
    end
    violation_verified_list.uniq! if violation_verified_list.present?

    return violation_verified_list
  end

  #Copy some fields values from Survivor Information to GBV Individual Details.
  def copy_survivor_information(case_record)
    copy_fields(case_record, {
        "survivor_code_no" => "survivor_code",
        "age" => "age",
        "date_of_birth" => "date_of_birth",
        "sex" => "sex",
        "gbv_ethnicity" => "ethnicity",
        "country_of_origin" => "country_of_origin",
        "gbv_nationality" => "nationality",
        "gbv_religion"  => "religion",
        "maritial_status" => "maritial_status",
        "gbv_displacement_status" => "displacement_status",
        "gbv_disability_type" => "disability_type",
        "unaccompanied_separated_status" => "unaccompanied_separated_status"
     })
  end

  def individual_ids
    ids = []
    if self.individual_details_subform_section.present?
      ids = self.individual_details_subform_section.map(&:id_number).compact
    end
    return ids
  end

  def set_violation_verification_default
    if self.violations.present?
      self.violations.to_hash.each do |key, value|
        value.each do |v|
          unless v.verified.present?
            v.verified = I18n.t('incident.violation.pending')
          end
        end
      end
    end
  end

  def index_violations
    if self.violations.present?
      Sunspot.index! Violation.from_incident(self)
    end
  end

  def unindex_violations
    if self.violations.present?
      Sunspot.remove! Violation.from_incident(self)
    end
  end

  #TODO - Need rspec test for this
  def child_types
    child_type_list = []
    ['boys', 'girls', 'unknown'].each do |child_type|
      child_type_list << child_type if (self.send("incident_total_tally_#{child_type}".to_sym).present? && self.send("incident_total_tally_#{child_type}".to_sym) > 0)
    end
    child_type_list += self.violation_child_types
    child_type_list.uniq! if child_type_list.present?

    return child_type_list
  end

  #Child types across all violations
  def violation_child_types
    child_type_list = []
    if self.violations.present?
      self.violations.to_hash.each do |key, value|
        value.each do |v|
          child_type_list += self.violation_children_list(key, v)
        end
      end
    end
    child_type_list.uniq! if child_type_list.present?

    return child_type_list
  end

  #Child types on a single violation
  def violation_children_list(violation_type, violation)
    child_list = []
    ['boys', 'girls', 'unknown'].each do |child_type|
      child_count = 0
      #Special case for "attack on hospitals" and "attack on schools"
      if(violation_type == 'attack_on_hospitals' || violation_type == 'attack_on_schools')
        child_count += violation.send("violation_killed_tally_#{child_type}".to_sym) if violation.send("violation_killed_tally_#{child_type}".to_sym).is_a?(Fixnum)
        child_count += violation.send("violation_injured_tally_#{child_type}".to_sym) if violation.send("violation_injured_tally_#{child_type}".to_sym).is_a?(Fixnum)
      else
        child_count += violation.send("violation_tally_#{child_type}".to_sym) if violation.send("violation_tally_#{child_type}".to_sym).is_a?(Fixnum)
      end
      if child_count > 0
        child_list << child_type
      end
    end
    return child_list
  end

  #TODO - Need rspec test for this
  def armed_force_group_names
    armed_force_groups = []
    if self.perpetrator_subform_section.present?
      self.perpetrator_subform_section.each {|p| armed_force_groups << p.armed_force_group_name if p.armed_force_group_name.present?}
    end
    armed_force_groups.uniq! if armed_force_groups.present?

    return armed_force_groups
  end

  #TODO - Need rspec test for this
  def perpetrator_sub_categories
    categories = []
    if self.perpetrator_subform_section.present?
      self.perpetrator_subform_section.each {|p| categories << p.perpetrator_sub_category if p.perpetrator_sub_category.present?}
    end
    categories.uniq! if categories.present?

    return categories
  end

  def clean_incident_date
    if date_of_incident_date_or_date_range == 'date'
      self.date_of_incident_from = nil
      self.date_of_incident_to = nil
    else
      self.date_of_incident = nil
    end
  end

  #TODO - Need rspec test for this
  def incident_date_derived
    return self.incident_date if self.incident_date.present?
    return self.date_of_incident_from if self.date_of_incident_from.present?
    return self.date_of_incident if self.date_of_incident.present?
    return nil
  end

  #To format the value in the export of the view list.
  def incident_date_to_export
    if self.date_of_incident_from.present? && self.date_of_incident_to.present?
      "#{self.date_of_incident_from.strftime('%d-%b-%Y')} - #{self.date_of_incident_to.strftime('%d-%b-%Y')}"
    elsif self.date_of_incident.present?
      self.date_of_incident.strftime("%d-%b-%Y")
    elsif self.incident_date.present?
      self.incident_date.strftime("%d-%b-%Y")
    end
  end

  #  TODO: The value 'Yes' may have to be translated
  def calculate_gbv_type_of_violence_exclusion
    if self.gbv_reported_elsewhere == 'Yes' && self.gbv_reported_elsewhere_subform.any?{ |f| f.gbv_reported_elsewhere_reporting == 'Yes' }
      self.gbv_do_not_report = ['Yes']
    else
      self.gbv_do_not_report = []
    end
  end

  # TODO: Combine/refactor this violations iterator to spit out instances of
  # TODO: Pavel's new Violation model
  def each_violation
    return enum_for(:each_violation) unless block_given?

    violations.keys.each do |cat|
      (violations[cat] || []).each do |v|
        yield v, cat
      end
    end
  end

  def find_violation_by_unique_id unique_id
    each_violation.inject(nil) do |acc, (v, cat)|
      if v.unique_id == unique_id
        acc = [cat, v]
      end
      acc
    end
  end
end
