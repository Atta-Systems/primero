# JIRA PRIMERO-133

@javascript @primero
Feature: Tracing Separation History
  As a Social Worker I want to fill in form information for children (individuals) in particular circumstances
  so that we can track and report on areas of particular concern.

  Scenario: As a logged in user, I should access the form section tracing
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "form section page"
    And I press the "Tracing" button
    Then I should see the following fields:
    | Name                                   |
    | Tracing Status                         |
    | Date of Separation                     |
    | What was the main cause of separation? |
    | Evacuated From                         |
    | Evacuated To                           |
    | Additional info that could help in tracing?|

  Scenario: As a logged in user, I create a case with tracing information
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "cases page"
    And I press the "Create a New Case" button
    And I press the "Tracing" button
    When I select "Open" from "Tracing Status"
    And I fill in the following:
      | Additional info that could help in tracing?    | Some Additional Information |
      | Details about what the child faced / witnessed | Some Additional Details     |
    And I press "Save"
    Then I should see "Case record successfully created" on the page
    When I press the "Tracing" button
    Then I should see a value for "Tracing Status" on the show page with the value of "Open"
    And I should see a value for "Additional info that could help in tracing?" on the show page with the value of "Some Additional Information"
    And I should see a value for "Details about what the child faced / witnessed" on the show page with the value of "Some Additional Details"