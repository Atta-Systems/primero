require 'spec_helper'

class MockFormSection

  def initialize is_valid = true
    @is_valid = is_valid
  end

  def base_language= base_language
    @base_language = base_language
  end

  def core_form= core_form
    @core_form = core_form
  end

  def unique_id= unique_id
    @unique_id = unique_id
  end

  def order= order
    @order = order
  end

  def order_form_group= order_form_group
    @order_form_group = order_form_group
  end

  def order_subform= order_subform
    @order_subform = order_subform
  end

  def valid?
    @is_valid
  end

  def create
    FormSection.new
  end

  def unique_id
    "unique_id"
  end

  def name
    "form_name"
  end
end

describe FormSectionController do
  before do
    FormSection.all.each &:destroy
    PrimeroModule.all.each &:destroy
    Role.all.each &:destroy

    @form_section_a = FormSection.create!(unique_id: "A", name: "A", parent_form: "case")
    @form_section_b = FormSection.create!(unique_id: "B", name: "B", parent_form: "case", mobile_form: true)
    @form_section_c = FormSection.create!(unique_id: "C", name: "C", parent_form: "case", mobile_form: true)
    @primero_module = PrimeroModule.create!(program_id: "some_program", name: "Test Module", associated_form_ids: ["A", "B"], associated_record_types: ['case'])
    user = User.new(:user_name => 'manager_of_forms', module_ids: [@primero_module.id])
    @permission_metadata = Permission.new(resource: Permission::METADATA, actions: [Permission::MANAGE])
    user.stub(:roles).and_return([Role.new(permissions_list: [@permission_metadata])])
    fake_login user
  end

  describe "get index" do
    it "populate the view with all the form sections in order ignoring enabled or disabled" do
      forms = [@form_section_a, @form_section_b]
      grouped_forms = forms.group_by{|e| e.form_group_name}

      get :index, :module_id => @primero_module.id, :parent_form => 'case'

      assigns[:form_sections].should == grouped_forms
    end

    it "only shows mobile forms if queried with a mobile parameter" do
      get :index, mobile: true, :format => :json
      expect(assigns[:form_sections].size).to eq(1)
      expect(assigns[:form_sections]['Children']).not_to be_nil
      expect(assigns[:form_sections]['Children'].first[:name]['en']).to eq('B')
    end

    it "sets null values on mobile API forms to be an empty string" do
      get :index, mobile: true, :format => :json
      expect(assigns[:form_sections]['Children'].first[:help_text]['en']).to eq('')
    end

    it "will only display requested locales if queried with a mobile parameter and a valid locale" do
      get :index, mobile: true, locale: 'en',  :format => :json
      expect(assigns[:form_sections]['Children'].first[:name]['en']).to eq('B')
      expect(assigns[:form_sections]['Children'].first[:name]['fr']).to be_nil
    end

    it "will display all locales if queried with a mobile parameter and an invalid locale" do
      get :index, mobile: true, locale: 'ABC',  :format => :json
      expect(assigns[:form_sections]['Children'].first[:name]['en']).to eq('B')
      expect(assigns[:form_sections]['Children'].first[:name].keys).to match_array(Primero::Application::locales)
    end
  end


  describe "forms API", :type => :request do
    it "gets the forms as JSON if accessed through the API url" do
      get '/api/forms'
      expect(response.content_type.to_s).to eq('application/json')
    end
  end

  describe "post create" do
    it "should new form_section with order" do
      existing_count = FormSection.count
      form_section = {:name=>"name", :description=>"desc", :help_text=>"help text", :visible=>true}
      post :create, :form_section => form_section
      FormSection.count.should == existing_count + 1
    end

    it "sets flash notice if form section is valid and redirect_to edit page with a flash message" do
      FormSection.stub(:new_custom).and_return(MockFormSection.new)
      form_section = {:name=>"name", :description=>"desc", :visible=>"true"}
      post :create, :form_section =>form_section
      request.flash[:notice].should == "Form section successfully added"
      response.should redirect_to(edit_form_section_path("unique_id"))
    end

    it "does not set flash notice if form section is valid and render new" do
      FormSection.stub(:new_custom).and_return(MockFormSection.new(false))
      form_section = {:name=>"name", :description=>"desc", :visible=>"true"}
      post :create, :form_section =>form_section
      request.flash[:notice].should be_nil
      response.should render_template("new")
    end

    it "should assign view data if form section was not valid" do
      expected_form_section = MockFormSection.new(false)
      FormSection.stub(:new_custom).and_return expected_form_section
      form_section = {:name=>"name", :description=>"desc", :visible=>"true"}
      post :create, :form_section =>form_section
      assigns[:form_section].should == expected_form_section
    end
  end

  describe "post save_order" do
    after { FormSection.all.each &:destroy }

    it "should save the order of the forms" do
      form_one = FormSection.create(:unique_id => "first_form", :name => "first form", :order => 1)
      form_two = FormSection.create(:unique_id => "second_form", :name => "second form", :order => 2)
      form_three = FormSection.create(:unique_id => "third_form", :name => "third form", :order => 3)
      post :save_order, :ids => [form_three.unique_id, form_one.unique_id, form_two.unique_id]
      FormSection.get_by_unique_id(form_one.unique_id).order.should == 2
      FormSection.get_by_unique_id(form_two.unique_id).order.should == 3
      FormSection.get_by_unique_id(form_three.unique_id).order.should == 1
      response.should redirect_to(form_sections_path)
    end
  end

  describe "post update" do
    it "should save update if valid" do
      form_section = FormSection.new
      params = {"some" => "params"}
      FormSection.should_receive(:get_by_unique_id).with("form_1", true).and_return(form_section)
      form_section.should_receive(:properties=).with(params)
      form_section.should_receive(:valid?).and_return(true)
      form_section.should_receive(:save!)
      post :update, :form_section => params, :id => "form_1"
      response.should redirect_to(edit_form_section_path(form_section.unique_id))
    end

    it "should show errors if invalid" do
      form_section = FormSection.new
      params = {"some" => "params"}
      FormSection.should_receive(:get_by_unique_id).with("form_1", true).and_return(form_section)
      form_section.should_receive(:properties=).with(params)
      form_section.should_receive(:valid?).and_return(false)
      post :update, :form_section => params, :id => "form_1"
      response.should_not redirect_to(form_sections_path)
      response.should render_template("edit")
    end
  end

  describe "post enable" do
    it "should toggle the given form_section to hide/show" do
      form_section1 = FormSection.create!({:name=>"name1", :description=>"desc", :visible=>"true", :unique_id=>"form_1"})
      form_section2 = FormSection.create!({:name=>"name2", :description=>"desc", :visible=>"false", :unique_id=>"form_2"})
      post :toggle, :id => "form_1"
      FormSection.get_by_unique_id(form_section1.unique_id).visible.should be_false
      post :toggle, :id => "form_2"
      FormSection.get_by_unique_id(form_section2.unique_id).visible.should be_true
    end
  end

  it "should only retrieve fields on a form that are visible" do
    FormSection.should_receive(:find_all_visible_by_parent_form).and_return({})
    get :published
  end

  it "should publish form section documents as json" do
    form_sections = [FormSection.new(:name => 'Some Name', :description => 'Some description')]
    FormSection.stub(:find_all_visible_by_parent_form).and_return(form_sections)

    get :published

    returned_form_section = JSON.parse(response.body).first
    returned_form_section["name"][I18n.locale.to_s].should == 'Some Name'
    returned_form_section["description"][I18n.locale.to_s].should == 'Some description'
  end

end
