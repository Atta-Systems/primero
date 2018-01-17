require 'rails_helper'

describe Report do

  before :all do
    @module = create :primero_module
  end

  it "must have a name" do
    r = Report.new record_type: "case", aggregate_by: ['a', 'b'], module_ids: [@module.id]
    expect(r.valid?).to be_falsey
    r.name = 'Test'
    expect(r.valid?).to be_truthy
  end

  it "must have an 'aggregate_by' value" do
    r = Report.new name: 'Test', record_type: 'case', module_ids: [@module.id]
    expect(r.valid?).to be_falsey
    r.aggregate_by = ['a', 'b']
    expect(r.valid?).to be_truthy
  end

  it "must have a record type associated with itself" do
    r = Report.new name: 'Test', aggregate_by: ['a', 'b'], module_ids: [@module.id]
    expect(r.valid?).to be_falsey
    r.record_type = 'case'
    expect(r.valid?).to be_truthy
  end

  it "doesn't point to invalid modules" do
    r = Report.new name: 'Test', aggregate_by: ['a', 'b'], module_ids: ['nosuchmodule', @module.id]
    expect(r.valid?).to be_falsey
  end

  it "lists reportable record types" do
    expect(Report.reportable_record_types).to include('case','incident', 'tracing_request', 'violation')
  end

  describe "nested reports" do

    it "lists reportsable nested record types" do
      expect(Report.reportable_record_types).to include('reportable_follow_up', 'reportable_protection_concern', 'reportable_service')
    end

    it "has default follow up filters" do
      r = Report.new(record_type: 'reportable_follow_up', add_default_filters: true)
      r.apply_default_filters
      expect(r.filters).to include({'attribute' => 'followup_date', 'constraint' => 'not_null'})
    end

    it "has default service filters" do
      r = Report.new(record_type: 'reportable_service', add_default_filters: true)
      r.apply_default_filters
      expect(r.filters).to include(
        {'attribute' => 'service_type', 'value' => 'not_null'},
        {'attribute' => 'service_appointment_date', 'constraint' => 'not_null'}
      )
    end

    it "has default protection concern filters" do
      r = Report.new(record_type: 'reportable_protection_concern', add_default_filters: true)
      r.apply_default_filters
      expect(r.filters).to include({'attribute' => 'protection_concern_type', 'value' => 'not_null'})
    end

  end

  describe "#value_vector" do
    it "will parse a Solr output to build a vector of pivot counts keyd by the pivot fields" do

      test_rsolr_output = {
        'pivot' => [
          {
            'value' => 'Somalia',
            'count' => 5,
            'pivot' => [
              {'value' => 'male', 'count' => 3},
              {'value'=> 'female', 'count' => 2},
            ]
          },
          {
            'value' => 'Burundi',
            'count' => 7,
            'pivot' => [
              {'value' => 'male', 'count' => 3},
              {'value' => 'female', 'count' => 4},
            ]
          },
          {
            'value' => 'Kenya',
            'count' => 9,
            'pivot' => [
              {'value' => 'male', 'count' => 5},
              {'value' => 'female', 'count' => 4},
            ]
          }
        ]
      }

      r = Report.new
      result = r.value_vector([],test_rsolr_output)
      expect(result).to match_array(
        [
          [["", ""], nil],
          [['Somalia',""],5],[['Somalia','male'],3],[['Somalia','female'],2],
          [['Burundi',""],7],[['Burundi','male'],3],[['Burundi','female'],4],
          [['Kenya',""],9],[['Kenya','male'],5],[['Kenya','female'],4]
        ]
      )
    end
  end

  describe "modules_present" do
    it "will reject the empty module_id list" do
      r = Report.new record_type: "case", aggregate_by: ['a', 'b'], module_ids: []
      r.modules_present.should == I18n.t("errors.models.report.module_presence")
    end

    it "will reject the invalid module_id list" do
      r = Report.new record_type: "case", aggregate_by: ['a', 'b'], module_ids: ["primeromodule-cp", "badmoduleid","primeromodule-gbv"]
      r.modules_present.should == I18n.t("errors.models.report.module_syntax")
    end

    it "will accept the valid module_id list" do
      r = Report.new record_type: "case", aggregate_by: ['a', 'b'], module_ids: ["primeromodule-cp"]
      r.modules_present.should == true
    end

  end

end
