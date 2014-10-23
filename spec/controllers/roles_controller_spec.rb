require 'spec_helper'

describe RolesController do

  describe "GET index" do

    it "should show page name" do
      fake_login_as([Permission::USER, Permission::READ, Permission::WRITE])
      mock = double()
      Role.should_receive(:by_name).and_return([mock])
      get :index
      assigns[:page_name].should == "Roles"
    end

    it "should allow user to view the roles" do
      fake_login_as([Permission::USER, Permission::READ, Permission::WRITE])
      mock = double()
      Role.should_receive(:by_name).and_return([mock])
      get :index
      response.should_not be_forbidden
      assigns(:roles).should == [mock]
    end

    it "should not allow user without view permission to view roles" do
      fake_login_as([Permission::SYSTEM])
      get :index
      response.should be_forbidden
    end
  end

  describe "GET edit" do

    it "should allow user to edit roles " do
      fake_login_as([Permission::USER, Permission::READ, Permission::WRITE])
      mock = stub_model Role, :id => "10"
      Role.should_receive(:get).with(mock.id).and_return(mock)
      get :edit, :id => mock.id
      response.should_not be_forbidden
      assigns(:role).should == mock
    end

    it "should not allow user without permission to edit roles" do
      fake_login_as([Permission::USER, Permission::READ])
      Role.stub :get => stub_model(Role)
      get :edit, :id => "10"
      response.should be_forbidden
    end

  end

  describe "GET show" do

    it "should allow user to view roles " do
      fake_login_as([Permission::USER, Permission::READ, Permission::WRITE])
      mock = stub_model Role, :id => "10"
      Role.should_receive(:get).with(mock.id).and_return(mock)
      get :show, :id => mock.id
      assigns(:role).should == mock
    end

    it "should not allow user without permission to edit roles" do
      fake_login_as([Permission::USER, Permission::READ])
      Role.stub :get => stub_model(Role)
      get :edit, :id => "10"
      response.should be_forbidden
    end

  end

  describe "POST new" do
    it "should allow valid user to create roles" do
      fake_login_as([Permission::USER, Permission::READ, Permission::WRITE])
      mock = stub_model Role
      Role.should_receive(:new).and_return(mock)
      post :new
      response.should_not be_forbidden
      assigns(:role).should == mock
    end

    it "should not allow user without permission to create new roles" do
      fake_login_as([Permission::USER, Permission::READ])
      Role.should_not_receive(:new)
      post :new
      response.should be_forbidden
    end
  end

  describe "POST update" do
    it "should allow valid user to update roles" do
      fake_login_as([Permission::USER, Permission::READ, Permission::WRITE])
      mock = stub_model Role, :id => "1"
      role_mock = { "mock" => "mock" }

      mock.should_receive(:update_attributes).with(role_mock).and_return(true)
      Role.should_receive(:get).with(mock.id).and_return(mock)
      post :update, :id => mock.id, :role => role_mock
      response.should_not be_forbidden
      assigns(:role).should == mock
      flash[:notice].should == "Role details are successfully updated."
    end

    it "should return error if update attributes is not invoked " do
      fake_login_as([Permission::USER, Permission::READ, Permission::WRITE])
      mock = stub_model Role, :id => "1"
      role_mock = { "mock" => "mock" }

      mock.should_receive(:update_attributes).with(role_mock).and_return(false)
      Role.should_receive(:get).with(mock.id).and_return(mock)
      post :update, :id => mock.id, :role => role_mock
      response.should_not be_forbidden
      assigns(:role).should == mock
      flash[:error].should == "Error in updating the Role details."
    end

    it "should not allow invalid user to update roles" do
      fake_login_as([Permission::USER, Permission::READ])
      mock = stub_model Role, :id => "1"
      mock.should_not_receive(:update_attributes).with(anything)
      Role.should_receive(:get).with(mock.id).and_return(mock)
      post :update, :id => mock.id, :role => {}
      response.should be_forbidden
    end
  end

  describe "POST create" do
    it "should not allow invalid user to create roles" do
      fake_login_as([Permission::USER, Permission::READ])
      role_mock = double()
      Role.should_not_receive(:new).with(anything)
      post :create, :role => role_mock
      response.should be_forbidden
    end

    it "should allow valid user to create roles" do
      fake_login_as([Permission::USER, Permission::READ, Permission::WRITE])
      role_mock = { "mock" => "mock" }
      role_mock.should_receive(:save).and_return(true)
      Role.should_receive(:new).with(role_mock).and_return(role_mock)
      post :create, :role => role_mock
      response.should redirect_to(roles_path)
      response.should_not be_forbidden
    end

    it "should take back to new page if save failed" do
      fake_login_as([Permission::USER, Permission::READ, Permission::WRITE])
      role_mock = double()
      role_mock.should_receive(:save).and_return(false)
      Role.should_receive(:new).with(anything).and_return(role_mock)
      post :create, :role => role_mock
      response.should render_template(:new)
      response.should_not be_forbidden
    end

  end

  describe "DELETE" do
    it "should allow a valid user to delete a role" do
      fake_login_as([Permission::USER, Permission::READ, Permission::WRITE, Permission::ALL])
      role = build :role
      role.should_receive(:destroy).and_return(true)
      Role.should_receive(:get).with("test-role").and_return(role)
      delete :destroy, id: "test-role"
      response.status.should_not == 403
    end
  end

end
