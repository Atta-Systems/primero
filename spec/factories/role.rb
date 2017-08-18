FactoryGirl.define do
  factory :role, :traits => [ :model ] do
    name { "test_role_#{counter}" }
    description "test description"
    permissions_list { Permission.all_permissions_list }
  end
end