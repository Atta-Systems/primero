require 'factory_girl'

FactoryGirl.define do
  trait :model do
    ignore do
      sequence(:counter, 1000000)
    end

    _id { "id-#{counter}" }
  end

  factory :child, :traits => [ :model ] do
    unique_identifier { counter.to_s }
    name { "Test Child #{counter}" }
    created_by "test_user"
    owned_by "test_user"
    module_id "CP"

    after_build do |child, factory|
      Child.stub(:get).with(child.id).and_return(child)
    end
  end

  factory :incident, :traits => [ :model ] do
    unique_identifier { counter.to_s }
    description { "Test Incident #{counter}" }
    created_by "test_user"
    owned_by "test_user"
    module_id "CP"

    after_build do |incident, factory|
      Incident.stub(:get).with(incident.id).and_return(incident)
    end
  end

  factory :tracing_request, :traits => [ :model ] do
    unique_identifier { counter.to_s }
    enquirer_name { "Test Tracing Request #{counter}" }
    created_by "test_user"
    owned_by "test_user"
    module_id "CP"

    after_build do |tracing_request, factory|
      TracingRequest.stub(:get).with(tracing_request.id).and_return(tracing_request)
    end
  end

  factory :location, :traits => [ :model ] do
    name { "location_#{counter}"}
    description { "location_#{counter}"}
  end

  factory :replication, :traits => [ :model ] do
    description 'Sample Replication'
    remote_app_url 'app:1234'
    username 'test_user'
    password 'test_password'
    remote_couch_config "target" => "http://couch:1234/replication_test"

    after_build do |replication|
      replication.stub :save_remote_couch_config => true
    end
  end

  factory :system_users do
    name 'test_user'
    password 'test_password'
    type 'user'
    roles ["admin"]
  end

  factory :change_password_form, :class => Forms::ChangePasswordForm do
    association :user
    old_password "old_password"
    new_password "new_password"
    new_password_confirmation "confirm_new_password"
  end

  factory :user, :traits => [ :model ] do
    user_name { "user_name_#{counter}" }
    full_name 'full name'
    password 'password'
    password_confirmation 'password'
    email 'email@ddress.net'
    organisation 'TW'
    disabled false
    verified true
    role_ids ['random_role_id']
    module_ids ['CP']
  end

  factory :role, :traits => [ :model ] do
    name { "test_role_#{counter}" }
    description "test description"
    permissions { Permission.all }
  end

  factory :primero_program, :traits => [:model] do
    name { "test_program_#{counter}"}
    description "test description"
  end

  factory :primero_module, :traits => [:model] do
    name { "test_module_#{counter}"}
    description "test description"
    program_id 'test-program'
    associated_record_types ['case']
    associated_form_ids ['test-form-1']
  end

  factory :lookup, :traits => [ :model ] do
    name { "test_lookup_#{counter}" }
    description "test description"
    lookup_values ['value1', 'value2']
  end

  factory :report, :traits => [ :model ] do
    ignore do
      filename "test_report.csv"
      content_type "text/csv"
      data "test report"
    end

    report_type { "weekly_report" }
    as_of_date { Date.today }

    after_build do |report, builder|
      report.create_attachment :name => builder.filename, :file => StringIO.new(builder.data), :content_type => builder.content_type if builder.data
    end
  end
end
