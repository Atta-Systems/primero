TEST_DATABASES = COUCHDB_SERVER.databases.select {|db| db =~ /#{ENV["RAILS_ENV"]}$/}

Before do
  Child.stub :index_record => true, :reindex! => true, :build_solar_schema => true
  Sunspot.stub :index => true, :index! => true
end

Before('@search') do
  RSpec::Mocks.proxy_for(Child).reset
  RSpec::Mocks.proxy_for(Sunspot).reset
  Sunspot.remove_all!(Child)
  Sunspot.remove_all!(Enquiry)
end

Before do
  I18n.locale = I18n.default_locale = :en
  CouchRest::Model::Base.descendants.each do |model|
    docs = model.database.documents["rows"].map { |doc|
      { "_id" => doc["id"], "_rev" => doc["value"]["rev"], "_deleted" => true } unless doc["id"].include? "_design"
    }.compact
    RestClient.post "#{model.database.root}/_bulk_docs", { :docs => docs }.to_json, { "Content-type" => "application/json" } unless docs.empty?
  end

  #Load the seed forms - Using 'load' method because 'require' will remember that
  #the files was already loaded and for the rest of scenarios will not execute
  #the code in the required file. 
  Dir[File.dirname(__FILE__) + '/../../db/forms/*.rb'].each {|file| load file }
end

Before('@roles') do |scenario|
  #TODO: Instead of the roles below, consider loading db/users/roles.rb
  Role.create(:name => 'Field Worker', :permissions => [Permission::CHILDREN[:register]])
  Role.create(:name => 'Field Admin', :permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:create], Permission::CHILDREN[:edit]])
  Role.create(:name => 'Admin', :permissions => Permission.all_permissions)
end


at_exit do
  TEST_DATABASES.each do |db|
    COUCHDB_SERVER.database(db).delete! rescue nil
  end
end