require 'spec_helper'

describe LookupsController do
  before do
    Lookup.all.each &:destroy

    @lookup_a = Lookup.create!(name: "A", lookup_values: ["A", "AA"])
    @lookup_b = Lookup.create!(name: "B", lookup_values: ["B", "BB", "BBB"])
    @lookup_c = Lookup.create!(name: "C", lookup_values: ["C", "CC", "CCC", "CCCC"])
    user = User.new(:user_name => 'manager_of_lookups')
    user.stub(:roles).and_return([Role.new(:permissions => [Permission::METADATA])])
    fake_login user
  end

  describe "get index" do
    it "populate the view with all the lookups" do
      lookups = [@lookup_a, @lookup_b, @lookup_c]
      get :index
      expect(assigns(:lookups)).to eq(lookups)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "post create" do
    it "should new form_section with order" do
      existing_count = Lookup.count
      lookup = {:name=>"name", lookup_values: ["Z", "ZZ", "ZZZ"]}
      post :create, lookup: lookup
      expect(Lookup.count).to eq(existing_count + 1)
    end

    it "sets flash notice if lookup is valid and redirect_to lookups page with a flash message" do
      lookup = {:name=>"name", lookup_values: ["Z", "ZZ", "ZZZ"]}
      post :create, lookup: lookup
      expect(request.flash[:notice]).to eq("Lookup successfully added")
      expect(response).to redirect_to(lookups_path)
    end
  end

  describe "post update" do
    it "should save update if valid" do
      @lookup_a.name = "lookup_1"
      Lookup.should_receive(:get).with("lookup_1").and_return(@lookup_a)
      post :update, id: "lookup_1"
      expect(response).to redirect_to(lookups_path)
    end

    it "should show errors if invalid" do
      @lookup_a.name = ""
      Lookup.should_receive(:get).with("lookup_1").and_return(@lookup_a)
      post :update, id: "lookup_1"
      expect(response).to_not redirect_to(lookups_path)
      expect(response).to render_template("edit")
    end
  end

  describe "post destroy" do
    it "should delete a lookup" do
      existing_count = Lookup.count
      post :destroy, id: @lookup_b.id
      expect(response).to redirect_to(lookups_path)
      expect(Lookup.count).to eq(existing_count - 1)
    end
  end
end
