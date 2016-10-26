require 'spec_helper'

describe Location do

  before do
    Location.all.each &:destroy

    @country = create :location, admin_level: 0, placename: 'MyCountry', type: 'country'
    @province1 = create :location, hierarchy: [@country.placename], type: 'province'
    @province2 = create :location, hierarchy: [@country.placename], type: 'state'
    @province3 = create :location, hierarchy: [@country.placename], type: 'province'
    @town1 = create :location, hierarchy: [@country.placename, @province1.placename], type: 'city'
    @town2 = create :location, hierarchy: [@country.placename, @province1.placename], type: 'city', disabled: false
    @town3 = create :location, hierarchy: [@country.placename, @province2.placename], type: 'city'
    @disabled1 = create :location, hierarchy: [@country.placename, @province2.placename], disabled: true
    @disabled2 = create :location, hierarchy: [@country.placename, @province2.placename], disabled: true

  end

  it '#hierarchical_name' do
    expect(@town1.hierarchical_name).to eq("#{@country.placename}::#{@province1.placename}::#{@town1.placename}")
  end

  it '#name' do
    expect(@town1.name).to eq(@town1.hierarchical_name)
  end

  describe 'all names' do
    it 'returns names for enabled locations' do
      expect(Location.all_names.count).to eq(7)
      expect(Location.all_names).to include(@country.name, @province1.name, @province2.name, @province3.name, @town1.name, @town2.name, @town3.name)
    end

    it 'does not return names for disabled locations' do
      expect(Location.all_names).not_to include(@disabled1.name, @disabled2.name)
    end
  end
  it 'returns all names' do
    expect(Location.all_names).to eq([@country.name, @province1.name, @province2.name, @province3.name, @town1.name, @town2.name, @town3.name])
  end

  it 'sets the #name to #hierarchical_name when saving' do
    @town1.placename = "Pawtucket"
    expect(@town1['name']).to_not eq(@town1.hierarchical_name)
    expect(@town1.name).to eq(@town1.hierarchical_name)
    @town1.save
    expect(@town1['name']).to eq(@town1.hierarchical_name)
    expect(@town1.name).to eq(@town1.hierarchical_name)
  end

  it "returns all descendants" do
    expect(@province1.descendants).to match_array [@town1, @town2]
    expect(@province2.descendants).to match_array [@town3, @disabled1, @disabled2]
    expect(@country.descendants).to match_array [@province1, @province2, @province3, @town1, @town2, @town3, @disabled1, @disabled2]
  end

  it "makes a single couchdb query to fetch a multi-level hierarchy" do
    expect(Location).to receive(:by_ancestor).once
    expect(Location).to_not receive(:get)
    expect(Location).to_not receive(:by_name)
    @country.descendants
  end

  it "adds location as a parent" do
    location1 = create :location, admin_level: 1
    location2 = create :location, admin_level: 0

    location1.set_parent(location2)

    expect(location2.descendants).to match_array [location1]
  end

  it "should only allow unique location hierachies" do
    country1 = Location.new(placename: 'USA', location_code: 'US', type: 'country', admin_level: 0)
    country1.save

    state1 = Location.new(placename: 'North Carolina', location_code: 'NC', type: 'state', hierarchy: [country1.placename])
    state1.save

    state2 = Location.new(placename: 'North Carolina', location_code: 'NC', type: 'state', hierarchy: [country1.placename])
    state2.save
    state2.should_not be_valid
    state2.errors[:name].should == ["A Location with that name already exists, please enter a different name"]
  end

  it "should allow locations with same placename but different hierachies" do
    country1 = Location.new(placename: 'USA', location_code: 'US', type: 'country', admin_level: 0)
    country1.save
    country2 = Location.new(placename: 'Canada', location_code: 'CA', type: 'country', admin_level: 0)
    country2.save

    state1 = Location.new(placename: 'North Carolina', location_code: 'NC', type: 'state', hierarchy: [country1.placename])
    state1.save

    state2 = Location.new(placename: 'North Carolina', location_code: 'NC', type: 'state', hierarchy: [country2.placename])
    state2.save
    state2.should be_valid
  end

  it "should not be valid if placename is empty" do
    location = Location.new(:location_code => "abc123")
    location.should_not be_valid
    location.errors[:name].should == ["must not be blank"]
  end

  describe 'type by admin level' do
    context 'when admin level is 0' do
      it 'returns location type' do
        expect(Location.type_by_admin_level(0)).to include('country')
      end
    end

    context 'when admin level is 1' do
      it 'returns location type' do
        expect(Location.type_by_admin_level(1)).to include('province', 'state')
      end
    end

    context 'when admin level is 2' do
      it 'returns location type' do
        expect(Location.type_by_admin_level(2)).to include('city')
      end
    end

    context 'when there are no locations for an admin level' do
      it 'returns an empty array' do
        expect(Location.type_by_admin_level(3)).to eq([])
      end
    end
  end

  describe 'ancestor by admin level' do
    context 'when admin level is 0' do
      it 'returns the ancestor' do
        expect(@town3.ancestor_by_admin_level(0)).to eq(@country)
      end
    end

    context 'when admin level is 1' do
      it 'returns the ancestor' do
        expect(@town3.ancestor_by_admin_level(1)).to eq(@province2)
      end
    end

    context 'when admin level is the same as the current locations admin level' do
      it 'does not return an ancestor' do
        expect(@town3.ancestor_by_admin_level(2)).to be_nil
      end
    end

    context 'when admin level is greater than the current locations admin level' do
      it 'does not return an ancestor' do
        expect(@town3.ancestor_by_admin_level(3)).to be_nil
      end
    end

    context 'when admin level is not in the valid range of admin levels' do
      it 'does not return an ancestor' do
        expect(@town3.ancestor_by_admin_level(99)).to be_nil
      end
    end
  end

  describe 'ancestor placename by name and admin level' do
    context 'when admin level is 0' do
      it 'returns the ancestor' do
        expect(Location.ancestor_placename_by_name_and_admin_level(@town3.name, 0)).to eq(@country.placename)
      end
    end

    context 'when admin level is 1' do
      it 'returns the ancestor' do
        expect(Location.ancestor_placename_by_name_and_admin_level(@town3.name, 1)).to eq(@province2.placename)
      end
    end

    context 'when admin level is the same as the current locations admin level' do
      it 'returns this locations placename' do
        expect(Location.ancestor_placename_by_name_and_admin_level(@town3.name, 2)).to eq(@town3.placename)
      end
    end

    context 'when admin level is greater than the current locations admin level' do
      it 'does not return an ancestor' do
        expect(Location.ancestor_placename_by_name_and_admin_level(@town3.name, 3)).to be_nil
      end
    end

    context 'when admin level is not in the valid range of admin levels' do
      it 'does not return an ancestor' do
        expect(Location.ancestor_placename_by_name_and_admin_level(@town3.name, 99)).to be_empty
      end
    end
  end

  describe 'admin level' do
    context 'when location has a parent' do
      before :each do
        @location = Location.new(placename: 'MyTown', location_code: 'abc123', hierarchy: [@country.placename])
      end

      it 'calculates admin_level' do
        expect(@location.calculate_admin_level).to eq((@country.admin_level + 1))
        expect(@location.admin_level).to eq((@country.admin_level + 1))
      end

      context 'and admin_level is empty' do
        it "is valid" do
          expect(@location).to be_valid
        end
      end

      context 'and admin_level is present' do
        before :each do
          @location[:admin_level] = 1
        end
        it "is valid" do
          expect(@location).to be_valid
        end
      end

      context 'and parents admin_level is equal to the max admin_level' do
        before :each do
          @country_max = create :location, admin_level: Location::ADMIN_LEVELS.last, placename: 'MaxCountry'
          @location[:hierarchy] = [@country_max.placename]
        end

        it 'calculates admin_level as out of range' do
          expect(@location.calculate_admin_level).to eq(Location::ADMIN_LEVEL_OUT_OF_RANGE)
          expect(@location.admin_level).to eq(Location::ADMIN_LEVEL_OUT_OF_RANGE)
        end
      end
    end

    context 'when location does not have a parent' do
      before :each do
        @location = Location.new(placename: 'MyTown', location_code: 'abc123')
      end

      context 'and admin_level is empty' do
        it "is not valid" do
          expect(@location).not_to be_valid
          expect(@location.errors[:admin_level]).to eq(['must not be blank'])
        end

        it 'does not calculate admin_level' do
          orig_admin_level = @location.admin_level
          expect(@location.calculate_admin_level).to be_nil
          expect(@location.admin_level).to eq(orig_admin_level)
        end
      end

      context 'and admin_level is present' do
        before :each do
          @location[:admin_level] = 1
        end
        it "is valid" do
          expect(@location).to be_valid
        end

        it 'does not calculate admin_level' do
          orig_admin_level = @location.admin_level
          expect(@location.calculate_admin_level).to be_nil
          expect(@location.admin_level).to eq(orig_admin_level)
        end
      end
    end
  end

  describe 'find_names_by_admin_level_enabled' do
    before do
      @another_country = create :location, admin_level: 0, placename: 'Another Country', type: 'country'
      @another_province = create :location, hierarchy: [@another_country.placename], type: 'province'
      @another_town1 = create :location, hierarchy: [@another_country.placename, @another_province.placename], type: 'city'
      @another_town2 = create :location, hierarchy: [@another_country.placename, @another_province.placename], type: 'city'
    end

    context 'when filter is not present' do
      it 'finds all location names for admin level' do
        expect(Location.find_names_by_admin_level_enabled(2)).to match_array([@town1.name, @town2.name, @town3.name, @another_town1.name, @another_town2.name])
      end
    end

    context 'when filter is present' do
      it 'finds all location names for admin level matching filter' do
        expect(Location.find_names_by_admin_level_enabled(2, @another_country.placename)).to match_array([@another_town1.name, @another_town2.name])
      end
    end
  end

  #TODO - location code validation was removed.
  #       this needs to be added back when that validation is added back
  xit "should not be valid if location code is empty" do
    location = Location.new(:placename => "test_location")
    location.should_not be_valid
    location.errors[:location_code].should == ["must not be blank"]
  end

  #TODO - for now, Location::BASE_TYPES returns a string of hard coded location type values
  #       When this is made I18n compliant, this test may need to be modified
  it 'returns all location types' do
    expect(Location::BASE_TYPES).to eq([
      'country', 'region', 'province', 'district', 'governorate', 
      'chiefdom', 'county', 'state', 'city', 'camp', 'site',
      'village', 'zone', 'other', 'locality', 'sub-district'
    ])
  end

  describe "Batch processing" do
    before do
      Location.all.each { |location| location.destroy }
    end

    it "should process in two batches" do
      country1 = Location.new(placename: 'USA', location_code: 'US', type: 'country', admin_level: 0)
      country1.save!

      country2 = Location.new(placename: 'Canada', location_code: 'CA', type: 'country', admin_level: 0)
      country2.save!

      state1 = Location.new(placename: 'North Carolina', location_code: 'NC', type: 'state', hierarchy: [country1.placename])
      state1.save!

      state2 = Location.new(placename: 'North Carolina', location_code: 'NC', type: 'state', hierarchy: [country2.placename])
      state2.save!

      expect(Location.all.page(1).per(3).all).to include(state2, state1, country2)
      expect(Location.all.page(2).per(3).all).to include(country1)
      Location.should_receive(:all).exactly(3).times.and_call_original

      records = []
      Location.each_slice(3) do |locations|
        locations.each{|l| records << l.placename}
      end

      records.should eq(["North Carolina", "North Carolina", "Canada", "USA"])
    end

    it "should process in 0 batches" do
      Location.should_receive(:all).exactly(1).times.and_call_original
      records = []
      Location.each_slice(3) do |location|
        locations.each{|l| records << l.placename}
      end
      records.should eq([])
    end

  end

end
