require 'spec_helper'

describe FieldsHelper do

  before(:all) do
    @child = Child.create(:name => "Simon", created_by: "bob")
    @child["nested_form_section"] = {
      "0"=>{"nested_1"=>"Keep", "nested_2"=>"Keep", "nested_3"=>"Keep"},
      "1"=>{"nested_1"=>"Drop", "nested_2"=>"Drop", "nested_3"=>"Drop"}
    }
    @child.save!
    @nested_field = Field.new({"name" => "nested_form_section",
               "type" => "subform", "editable" => true,
               "display_name_all" => "Top 2 Subform"})
  end

  before :each do
    @fields_helper = Object.new.extend FieldsHelper
  end

   it "should give back tuples of form unique id and display name" do
     first_form = FormSection.new(:name => nil, :unique_id => "first_form", :parent_form => "case")
     second_form = FormSection.new(:name => "Third Form", :unique_id => "third_form", :parent_form => "case")
     third_form = FormSection.new(:name => "Middle Form", :unique_id => "middle_form", :parent_form => "case")
     FormSection.stub(:all).and_return [first_form, second_form, third_form]

     @fields_helper.forms_for_display.should == [[nil, "first_form"], ["Middle Form", "middle_form"], ["Third Form", "third_form"]]
   end

  describe "option_fields" do
    it "should return empty array when suggestions is nil" do
      suggested_field = double(:field => double(:option_strings => nil))
      @fields_helper.option_fields_for(nil, suggested_field).should be_empty
    end

    it "should return empty array when suggestions is empty" do
      suggested_field = double(:field => double(:option_strings => []))
      @fields_helper.option_fields_for(nil, suggested_field).should be_empty
    end

    it "should return array of hidden fields for array of suggestions" do
      form = double("form helper")
      form.should_receive(:hidden_field).with("option_strings_text", hash_including(:multiple => true, :id => "option_string_1", :value => "1\n")).once.and_return("X")
      form.should_receive(:hidden_field).with("option_strings_text", hash_including(:multiple => true, :id => "option_string_2", :value => "2\n")).once.and_return("Y")

      suggested_field = double(:field => double(:option_strings => ["1", "2"]))
      option_fields = @fields_helper.option_fields_for(form, suggested_field)
      option_fields.should == ["X", "Y"]
    end
  end


  describe "field_tag_name" do
    it "should build a tag name from the array of keys" do
      tag_name = @fields_helper.field_tag_name(@child, @nested_field, ["nested_form_section", "0"])
      expect(tag_name).to eq("child[nested_form_section][0]")
    end
  end

  describe "field_value" do
    it "should return a value of a nested form for an existing child" do
      value = @fields_helper.field_value(@child, @nested_field, ["nested_form_section", "0"])
      expect(value).to eq({"nested_1"=>"Keep", "nested_2"=>"Keep", "nested_3"=>"Keep"})
    end
  end

  describe "subforms_count" do
    it "should return the number of nested subforms" do
      count = @fields_helper.subforms_count(@child, @nested_field)
      expect(count).to eq(2)
    end
  end


end
