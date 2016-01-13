class ReportableProtectionConcern

  def self.parent_record_type
    Child
  end

  def self.record_field_name
    'protection_concern_detail_subform_section'
  end

  def self.report_filters
    [
      {'attribute' => 'child_status', 'value' => ['Open']},
      {'attribute' => 'record_state', 'value' => ['true']},
      {'attribute' => 'protection_concern_type', 'value' => 'not_null'}
    ]
  end


  include ReportableNestedRecord

  searchable do
    extend ReportableNestedRecord::Searchable
    configure_searchable(ReportableProtectionConcern)
  end

  def id
    object_value('unique_id')
  end

end