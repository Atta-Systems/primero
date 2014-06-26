# JIRA PRIMERO-165
# JIRA PRIMERO-192
# JIRA PRIMERO-232

@javascript @primero
Feature: Care Arrangement
  As a Social Worker, I want to fill in form information for children (individuals) in particular circumstances, 
  so that we can track and report on areas of particular concern.

  Scenario: As a logged in user, I should access the form section care arrangement
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "form section page"
    And I press the "Care Arrangement" button
    Then I should see the following fields:
    | Is this a same caregiver as was previously entered for the child?       |
    | If this is a new caregiver, give the reason for the change              |
    | Care Arrangement Notes                                                  |
    | Name of Agency Providing Care Arrangements                              |
    | Relationship of the Caregiver to the Child                              |
    | Does the caregiver know the family of the child?                        |
    | Other information from the caregiver about the child and his/her family |

  Scenario: As a logged in user, I create a case with care arrangement information
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "cases page"
    And I press the "Create a New Case" button
    And I press the "Care Arrangement" button
    And I select "Yes" for "Is this a same caregiver as was previously entered for the child?" radio button
    And I select "Education" from "If this is a new caregiver, give the reason for the change"
    And I select "Residential Care Center" from "What are the child's current care arrangements?"
    And I select "Grandmother" from "Relationship of the Caregiver to the Child"
    And I select "No" for "Is caregiver willing to continue taking care of the child?" radio button
    And I fill in the following:
      | Care Arrangement Notes                                                  | Some Care Arrangement Notes               |
      | Name of Current Caregiver                                               | Some Name of Current Caregiver            |
      | Caregiver's Identification - Type and Number                            | Type and Number                           |
      | Caregiver's Age                                                         | 40                                        |
      | Other information from the caregiver about the child and his/her family | Some other information from the caregiver |
    And I press "Save"
    Then I should see "Case record successfully created" on the page
    And I press the "Care Arrangement" button
    And I should see a value for "Is this a same caregiver as was previously entered for the child?" on the show page with the value of "Yes"
    And I should see a value for "If this is a new caregiver, give the reason for the change" on the show page with the value of "Education"
    And I should see a value for "What are the child's current care arrangements?" on the show page with the value of "Residential Care Center"
    And I should see a value for "Relationship of the Caregiver to the Child" on the show page with the value of "Grandmother"
    And I should see a value for "Is caregiver willing to continue taking care of the child?" on the show page with the value of "No"
    And I should see a value for "Care Arrangement Notes" on the show page with the value of "Some Care Arrangement Notes"
    And I should see a value for "Name of Current Caregiver" on the show page with the value of "Some Name of Current Caregiver"
    And I should see a value for "Caregiver's Identification - Type and Number" on the show page with the value of "Type and Number"
    And I should see a value for "Caregiver's Age" on the show page with the value of "40"
    And I should see a value for "If yes, what is the future address?" on the show page with the value of ""
    And I should see a value for "What is the future location?" on the show page with the value of ""
    And I should see a value for "Other information from the caregiver about the child and his/her family" on the show page with the value of "Some other information from the caregiver"