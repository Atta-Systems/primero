require 'spec_helper'

describe Report do

  before :all do
    @module = create :primero_module
  end

  it "must have a name" do
    r = Report.new record_type: "case", aggregate_by: ['a', 'b'], module_ids: [@module.id]
    expect(r.valid?).to be_false
    r.name = 'Test'
    expect(r.valid?).to be_true
  end

  it "must have an 'aggregate_by' value" do
    r = Report.new name: 'Test', record_type: 'case', module_ids: [@module.id]
    expect(r.valid?).to be_false
    r.aggregate_by = ['a', 'b']
    expect(r.valid?).to be_true
  end

  it "must have a record type associated with itself" do
    r = Report.new name: 'Test', aggregate_by: ['a', 'b'], module_ids: [@module.id]
    expect(r.valid?).to be_false
    r.record_type = 'case'
    expect(r.valid?).to be_true
  end

  it "doesn't point to invalid modules" do
    r = Report.new name: 'Test', aggregate_by: ['a', 'b'], module_ids: ['nosuchmodule', @module.id]
    expect(r.valid?).to be_false
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

end
