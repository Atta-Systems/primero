
require 'rails_helper'

_Model = Class.new(CouchRest::Model::Base) do
  include Ownable

  def save_doc(*args)
    true
  end
end

describe Ownable do
  before :each do
    @superuser = create :user
    @field_worker = create :user
    @inst = _Model.create({:owned_by => @superuser.user_name})
  end

  it 'sets the owned_by field to null upon save if user does not exist' do
    @inst.owned_by.should == @superuser.user_name
    @inst.owned_by = 'non-existent user'
    @inst.save!
    @inst.owned_by.should be_nil
  end

  it 'sets the owned_by_agency and owned_by_location upon save' do
    @inst.owned_by_agency.should == @superuser.organization
    @inst.owned_by_location.should == @superuser.location
    @inst.owned_by = @field_worker.user_name
    @inst.save!
    @inst.owned_by_agency.should == @field_worker.organization
    @inst.owned_by_location.should == @field_worker.location
  end
end
