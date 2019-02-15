require 'rails_helper'
require 'sunspot'

feature "show page", search: true do
  feature "edit users" do
    before do
      Sunspot.setup(User) do
        string :user_name
        string :organization
        string :location
        boolean :disabled
      end

      Sunspot.remove_all!

      Role.all.each &:destroy
      User.all.each &:destroy
      Agency.all.each &:destroy

      @agency_user_admin = create(:role, name: "agency_user_admin", description: "agency user admin test", permissions_list: [Permission.new(:resource => Permission::USER, :actions => [Permission::AGENCY_READ, Permission::WRITE, Permission::ASSIGN, Permission::MANAGE])])
      @agency1 = create(:agency, name: "agency1", agency_code: "AGENCY1")
      @agency2 = create(:agency, name: "agency2", agency_code: "AGENCY2")
      @user = setup_user(organization: @agency1.id, roles: @agency_user_admin)
      @user2 = setup_user(organization: @agency1.id)
      @user3 = setup_user(organization: @agency2.id)
      Sunspot.commit
    end

    scenario "as agency user admin and sees only users in same agency" do
      create_session(@user, 'password123')
      visit "/users"
      expect(page).to have_content @user.user_name
      expect(page).to have_content @user2.user_name
      expect(page).to_not have_content @user3.user_name
    end

    scenario "as admin and sees all users" do
      create_session(@user2, 'password123')
      visit "/users"
      expect(page).to have_content @user.user_name
      expect(page).to have_content @user2.user_name
      expect(page).to have_content @user3.user_name
    end
  end
end
