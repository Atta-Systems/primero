# JIRA PRIMERO-114
# JIRA PRIMERO-195

@javascript @primero
Feature: Tracing Subforms
  As a Social Worker I want to fill in form information for children's tracing actions.

  Background:
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "cases page"
    And I press the "Create a New Case" button
    And I press the "Tracing" button

  Scenario: As a logged in user, I should access the form section tracing and create tracing actions
    And I fill in the 1st "Tracing Actions Section" subform with the follow:
      | Date of tracing                                      | 30/May/2014               |
      | Action taken and remarks                             | Test remarks              |
      | Address/Village where the tracing action took place  | Test Village              |
      | Outcome of tracing action                            | <Select> Pending          |
      | Place of tracing                                     | <Select> Kenya            |
      | Type of action taken                                 | <Select> Photo Tracing    |
    And I fill in the 2nd "Tracing Actions Section" subform with the follow:
      | Date of tracing                                      | 30/June/2014              |
      | Action taken and remarks                             | Test remarks2             |
      | Address/Village where the tracing action took place  | Test Village2             |
      | Outcome of tracing action                            | <Select> Unsuccessful     |
      | Place of tracing                                     | <Select> Nepal            |
      | Type of action taken                                 | <Select> Mass Tracing     |
    And I press "Save"
    Then I should see "Case record successfully created" on the page
    And I press the "Tracing" button
    And I should see "Kenya" on the page
    And I should see "Nepal" on the page

  Scenario: As a logged in user, I should access the form section tracing and add/remove tracing actions
    And I fill in the 1st "Tracing Actions Section" subform with the follow:
      | Date of tracing                                      | 30/May/2014               |
      | Action taken and remarks                             | Test remarks              |
      | Address/Village where the tracing action took place  | Test Village              |
      | Outcome of tracing action                            | <Select> Pending          |
      | Place of tracing                                     | <Select> Kenya            |
      | Type of action taken                                 | <Select> Photo Tracing    |
    And I fill in the 2nd "Tracing Actions Section" subform with the follow:
      | Date of tracing                                      | 30/June/2014              |
      | Action taken and remarks                             | Test remarks2             |
      | Address/Village where the tracing action took place  | Test Village2             |
      | Outcome of tracing action                            | <Select> Unsuccessful     |
      | Place of tracing                                     | <Select> Nepal            |
      | Type of action taken                                 | <Select> Mass Tracing     |
    And I press "Save"
    Then I should see "Case record successfully created" on the page
    And I press the "Edit" button
    And I remove the 1st "Tracing Actions Section" subform
    And I click OK in the browser popup
    And I fill in the 3rd "Tracing Actions Section" subform with the follow:
      | Date of tracing                                      | 10/June/2014              |
      | Action taken and remarks                             | Test remarks3             |
      | Address/Village where the tracing action took place  | Test Village3             |
      | Outcome of tracing action                            | <Select> Successful       |
      | Place of tracing                                     | <Select> Uganda           |
      | Type of action taken                                 | <Select> Photo Tracing    |
    And I press "Save"
    Then I should not see "Kenya" on the page
    And I should see "Uganda" on the page
    And I should see "Nepal" on the page

  Scenario: As a logged in user, I should access the form section tracing and remove the last tracing action
    And I fill in the 1st "Tracing Actions Section" subform with the follow:
      | Date of tracing                                      | 30/May/2014               |
      | Action taken and remarks                             | Test remarks              |
      | Address/Village where the tracing action took place  | Test Village              |
      | Outcome of tracing action                            | <Select> Pending          |
      | Place of tracing                                     | <Select> Kenya            |
      | Type of action taken                                 | <Select> Photo Tracing    |
    And I press "Save"
    Then I should see "Case record successfully created" on the page
    And I press the "Edit" button
    And I remove the 1st "Tracing Actions Section" subform
    And I click OK in the browser popup
    And I press "Save"
    Then I should not see "Kenya" on the page