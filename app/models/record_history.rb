class RecordHistory < ActiveRecord::Base
  belongs_to :record, polymorphic: true

  def user
    @user || User.get(self.user_name)
  end

  #TODO: This is an N+1 performance issue
  def user_organization
    self.user.organization
  end

end