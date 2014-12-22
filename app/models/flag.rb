class Flag
  include Syncable::PrimeroEmbeddedModel
  include PrimeroModel

  validate :validate_record

  property :date, Date
  property :message, String
  property :flagged_by, String
  property :removed, TrueClass
  property :unflag_message, String
  property :created_at, Date
  property :system_generated_followup, TrueClass, :default => false
  property :id

  # alias_method :index_flags, :index

  include Sunspot::Rails::Searchable

  searchable do
    date :flag_date, :stored => true do
      self.date.present? ? self.date : nil
    end
    date :flag_created_at, :stored => true do
      self.created_at.present? ? self.created_at : nil
    end
    string :flag_message, :stored => true do
      self.message
    end
    string :flag_unflag_message, :stored => true do
      self.unflag_message
    end
    string :flag_flagged_by, :stored => true do
      self.flagged_by
    end
    string :flag_flagged_by_module, :stored => true do
      base_doc.module_id
    end
    boolean :flag_is_removed, :stored => true do
      self.removed ? true : false
    end
    boolean :flag_system_generated_followup, :stored => true do
      self.system_generated_followup
    end
    string :flag_record_id, :stored => true do
      base_doc.id
    end
    string :flag_record_type, :stored => true do
      base_doc.class.to_s.underscore.downcase
    end
    string :flag_record_short_id, :stored => true do
      base_doc.short_id
    end
    string :flag_child_name, :stored => true do
      base_doc.name
    end
    string :flag_module_id, :stored => true do
      base_doc.module_id
    end
    string :flag_incident_date_of_first_report, :stored => true do
      base_doc.date_of_first_report
    end
    string :flag_incident_location, :stored => true do
      base_doc.incident_location
    end
  end

  Sunspot::Adapters::InstanceAdapter.register DocumentInstanceAccessor, self
  Sunspot::Adapters::DataAccessor.register DocumentDataAccessor, self

  def initialize *args
    super

    self.id ||= UUIDTools::UUID.random_create.to_s
  end

  def parent_record
    base_doc
  end

  private

  def validate_record
    errors.add(:message, I18n.t("errors.models.flags.message")) unless self.message.present?
    unless self.date.blank? || self.date.is_a?(Date)
      begin
        Date.parse(self.date)
      rescue
        errors.add(:date, I18n.t("errors.models.flags.date"))
      end
    end
  end
end
