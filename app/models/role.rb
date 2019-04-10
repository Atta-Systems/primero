class Role < ActiveRecord::Base

  #include Importable #TODO: This will need to be rewritten
  include Memoizable

  has_and_belongs_to_many :form_sections
  has_and_belongs_to_many :roles

  validates :permissions_list, presence: { message: I18n.t("errors.models.role.permission_presence") }
  validates :name, presence: { message: I18n.t("errors.models.role.name_present") },
                   uniqueness: { message: I18n.t("errors.models.role.unique_name") }

  before_create :generate_unique_id
  before_save :add_permitted_subforms

  scope :by_referral, -> { where(referral: true) }
  scope :by_transfer, -> { where(transfer: true) }

  # input: either an action string (ex: read, write, flag, etc)
  #        or a colon separated string, with the first part being resource, action, or management,
  #        and the second being the value (ex: read, write, case, incident, etc)
  def has_permission(permission)
    perm_split = permission.split(':')

    #if input is a single string, not colon separated, then default the key to actions
    perm_key = (perm_split.count == 1) ? 'actions' : perm_split.first
    perm_value = perm_split.last

    if perm_key == 'management'
      self.group_permission == perm_value
    else
      self.permissions_list.map{|p| p[perm_key]}.flatten.include? perm_value
    end
  end

  def has_permitted_form_id?(form_unique_id_id)
    self.form_sections.map(&:unique_id).include?(form_unique_id_id)
  end

  def add_permitted_subforms
    if self.form_sections.present?
      subforms = FormSection.get_subforms(self.form_sections)
      all_permitted_form = self.form_sections | subforms
      if all_permitted_form.present?
        self.form_sections << subforms
      end
    end
  end

  def permissions
    if self.permissions_list.present?
      self.permissions_list.map{|p| Permission.new(p)}
    else
      []
    end
  end

  def permissions=(permissions)
    if permissions.is_a? Array
      self.permissions_list = permissions.map(&:to_h)
    end
  end

  class << self

    def memoized_dependencies
      [FormSection, PrimeroModule, User]
    end

    #TODO: Used by importer. Refactor?
    def get_unique_instance(attributes)
      find_by_name(attributes['name'])
    end

    def names_and_ids_by_referral
      self.by_referral.pluck(:name, :unique_id)
    end
    # memoize_in_prod :names_and_ids_by_referral

    def names_and_ids_by_transfer
      self.by_transfer.pluck(:name, :unique_id)
    end
    # memoize_in_prod :names_and_ids_by_transfer

    def create_or_update(attributes = {})
      record = self.find_by(unique_id: attributes[:unique_id])
      if record.present?
        record.update_attributes(attributes)
      else
        self.create!(attributes)
      end
    end

    def id_from_name(name)
      "#{self.name}-#{name}".parameterize.dasherize
    end
  end

  def associated_role_ids
    self.roles.ids.flatten
  end


  def is_super_user_role?
    superuser_resources = [
      Permission::CASE, Permission::INCIDENT, Permission::REPORT,
      Permission::ROLE, Permission::USER, Permission::USER_GROUP,
      Permission::AGENCY, Permission::METADATA, Permission::SYSTEM
    ]
    has_managed_resources?(superuser_resources)
  end

  def is_user_admin_role?
    admin_only_resources = [
      Permission::ROLE, Permission::USER, Permission::USER_GROUP,
      Permission::AGENCY, Permission::METADATA, Permission::SYSTEM
    ]
    has_managed_resources?(admin_only_resources)
  end

  def generate_unique_id
    if self.name.present? && self.unique_id.blank?
      self.unique_id = "#{self.class.name}-#{self.name}".parameterize.dasherize
    end
  end

  def associate_all_forms
    permissions_with_forms = self.permissions.select{|p| p.resource.in?([Permission::CASE, Permission::INCIDENT, Permission::TRACING_REQUEST])}
    forms_by_parent = FormSection.all_forms_grouped_by_parent
    permissions_with_forms.map do |permission|
      self.form_sections << forms_by_parent[permission.resource]
      self.save
    end
  end

  private

  def has_managed_resources?(resources)
    current_managed_resources = self.permissions.select{ |p| p.actions == [Permission::MANAGE] }.map(&:resource)
    (resources - current_managed_resources).empty?
  end

end

