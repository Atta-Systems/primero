# frozen_string_literal: true

require 'rails_helper'

describe ManagedReports::Indicators::Perpetrators do
  before do
    clean_data(Incident, Violation, Perpetrator, UserGroup, User, Agency, Role)

    permissions = [
      Permission.new(
        resource: Permission::MANAGED_REPORT,
        actions: [
          Permission::VIOLATION_REPORT
        ]
      )
    ]
    self_role = Role.create!(
      name: 'Self Role 1',
      unique_id: 'self-role-1',
      group_permission: Permission::SELF,
      permissions: permissions
    )

    group_role = Role.create!(
      name: 'Group Role 1',
      unique_id: 'group-role-1',
      group_permission: Permission::GROUP,
      permissions: permissions
    )

    agency_role = Role.create!(
      name: 'Agency Role 1',
      unique_id: 'agency-role-1',
      group_permission: Permission::AGENCY,
      permissions: permissions
    )

    all_role = Role.create!(
      name: 'All Role 1',
      unique_id: 'all-role-1',
      group_permission: Permission::ALL,
      permissions: permissions
    )

    agency_a = Agency.create!(name: 'Agency 1', agency_code: 'agency1', unique_id: 'agency1')
    agency_b = Agency.create!(name: 'Agency 2', agency_code: 'agency2', unique_id: 'agency2')

    group_a = UserGroup.create(unique_id: 'group-a', name: 'Group A')
    group_b = UserGroup.create(unique_id: 'group-b', name: 'Group B')

    @self_user = User.create!(
      full_name: 'Self User',
      user_name: 'self_user',
      email: 'self_user@localhost.com',
      agency_id: agency_a.id,
      user_groups: [group_a],
      role: self_role
    )

    @group_user = User.create!(
      full_name: 'Group User',
      user_name: 'group_user',
      email: 'group_user@localhost.com',
      agency_id: agency_b.id,
      user_groups: [group_b],
      role: group_role
    )

    @agency_user = User.create!(
      full_name: 'Agency User',
      user_name: 'agency_user',
      email: 'agency_user@localhost.com',
      agency_id: agency_b.id,
      user_groups: [group_b],
      role: agency_role
    )

    @all_user = User.create!(
      full_name: 'all User',
      user_name: 'all_user',
      email: 'all_user@localhost.com',
      agency_id: agency_a.id,
      user_groups: [group_a, group_b],
      role: all_role
    )

    incident1 = Incident.new_with_user(@self_user, { incident_date: Date.today, status: 'open' })
    incident1.save!
    incident2 = Incident.new_with_user(@group_user, { incident_date: Date.today, status: 'open' })
    incident2.save!
    incident3 = Incident.new_with_user(@agency_user, { incident_date: Date.today, status: 'open' })
    incident3.save!
    incident4 = Incident.new_with_user(@all_user, { incident_date: Date.today, status: 'open' })
    incident4.save!

    violation1 = Violation.create!(data: { type: 'killing', attack_type: 'arson',
                                           violation_tally: { 'boys': 1, 'girls': 1, 'unknown': 1, 'total': 3 } },
                                   incident_id: incident1.id)
    violation1.perpetrators = [Perpetrator.create!(data: { armed_force_group_party_name: 'armed_force_2' })]

    violation2 = Violation.create!(data: { type: 'killing', attack_type: 'aerial_attack',
                                           violation_tally: { 'boys': 1, 'girls': 1, 'unknown': 1, 'total': 3 } },
                                   incident_id: incident2.id)
    violation2.perpetrators = [Perpetrator.create!(data: { armed_force_group_party_name: 'armed_force_2' })]

    violation3 = Violation.create!(data: { type: 'maiming', attack_type: 'aerial_attack',
                                           violation_tally: { 'boys': 1, 'girls': 1, 'unknown': 4, 'total': 6 } },
                                   incident_id: incident3.id)
    violation3.perpetrators = [Perpetrator.create!(data: { armed_force_group_party_name: 'armed_force_3' })]

    violation4 = Violation.create!(data: { type: 'killing', attack_type: 'arson',
                                           violation_tally: { 'boys': 3, 'girls': 1, 'unknown': 1, 'total': 5 } },
                                   incident_id: incident4.id)
    violation4.perpetrators = [Perpetrator.create!(data: { armed_force_group_party_name: 'armed_force_4' })]
  end

  it 'returns data for perpetrators indicator' do
    perpetrators_data = ManagedReports::Indicators::Perpetrators.build(
      nil,
      { 'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing') }
    ).data

    expect(perpetrators_data).to match_array(
      [
        { boys: 2, girls: 2, id: 'armed_force_2', total: 6, unknown: 2 },
        { boys: 3, girls: 1, id: 'armed_force_4', total: 5, unknown: 1 }
      ]
    )
  end

  describe 'records in scope' do
    it 'returns owned records for a self scope' do
      perpetrators_data = ManagedReports::Indicators::Perpetrators.build(
        @self_user,
        { 'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing') }
      ).data

      expect(perpetrators_data).to match_array(
        [
          { boys: 1, girls: 1, unknown: 1, total: 3, id: 'armed_force_2' }
        ]
      )
    end

    it 'returns group records for a group scope' do
      perpetrators_data = ManagedReports::Indicators::Perpetrators.build(
        @group_user,
        { 'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing') }
      ).data

      expect(perpetrators_data).to match_array(
        [
          { boys: 1, girls: 1, unknown: 1, total: 3, id: 'armed_force_2' },
          { boys: 3, girls: 1,  unknown: 1, total: 5, id: 'armed_force_4', }
        ]
      )
    end

    it 'returns agency records for an agency scope' do
      perpetrators_data = ManagedReports::Indicators::Perpetrators.build(
        @agency_user,
        { 'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing') }
      ).data

      expect(perpetrators_data).to match_array(
        [
          { boys: 1, girls: 1, unknown: 1, total: 3, id: 'armed_force_2' }
        ]
      )
    end

    it 'returns all records for an all scope' do
      perpetrators_data = ManagedReports::Indicators::Perpetrators.build(
        @all_user,
        { 'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing') }
      ).data

      expect(perpetrators_data).to match_array(
        [
          { boys: 2, girls: 2, id: 'armed_force_2', total: 6, unknown: 2 },
          { boys: 3, girls: 1, id: 'armed_force_4', total: 5, unknown: 1 }
        ]
      )
    end
  end
end