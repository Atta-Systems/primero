# JIRA PRIMERO-123
# JIRA PRIMERO-232

@javascript @primero
Feature: Child Under 5
  As a Social Worker, I want to fill in form information for children (individuals) in particular circumstances 
  so that we can track and report on areas of particular concern.

  Scenario: As a logged in user, I should access the form section child under 5
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "form section page"
    And I press the "Child Under 5" button
    Then I should see the following fields:
    | Date child was found                   |
    | Exact location where child was found   |
    | Found in Village/Area/Physical Address |
    | Please describe in detail how the child was found or taken in the family/children's center   |
    | Where are the people who were part of the group that was displaced at the same time?          |
    | Village/Area/Physical Address |
    | Name of person who gave the child to the family/children's center?                   |
    | What is this person's relationship to the child?                   |
    | Location of person who found the child                   |
    | Address of person who found the child                   |
    | If that person's address is not known, how could we find him or her and/or provide name(s) and address(es) who may know the person who found the child?                   |
    | Are there any clothes and belongings the child was found with?                   |
    | Please list and describe (including medals, bracelets, hair ties, etc.)                   |
    | Please write down any stories, songs, words, most often repeated by the child                  |
    | If the child speaks with an accent and if the family separation has been short (few months), from what region do you think the child comes from?                   |
    | Please write down any behavior specific to the child that may help a parent identify him/her later on such as child's games, and main interests or specific things he/she likes to do                   |
    
    
  Scenario: As a logged in user, I create a case with child under 5 information
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "cases page"
    And I press the "Create a New Case" button
    And I press the "Child Under 5" button
    And I fill in the following:
      | Date child was found                   | 15/Sep/2014              |
      | Exact location where child was found   | Location child was found |
      | Found in Village/Area/Physical Address | Village Found Address    |
      | If the child speaks with an accent and if the family separation has been short (few months), from what region do you think the child comes from?                                      | Region child come from    |
      | Please write down any behavior specific to the child that may help a parent identify him/her later on such as child's games, and main interests or specific things he/she likes to do | Child games, Main Interest|
      | Please describe in detail how the child was found or taken in the family/children's center | Details about how the child was found in the family center. |
    And I select "Yes" for "Are there any clothes and belongings the child was found with?" radio button
    And I press "Save"
    Then I should see "Case record successfully created" on the page
    And I press the "Child Under 5" button
    And I should see a value for "Date child was found" on the show page with the value of "15/Sep/2014"
    And I should see a value for "Exact location where child was found" on the show page with the value of "Location child was found"
    And I should see a value for "Found in Village/Area/Physical Address" on the show page with the value of "Village Found Address"
    And I should see a value for "If the child speaks with an accent and if the family separation has been short (few months), from what region do you think the child comes from?" on the show page with the value of "Region child come from"
    And I should see a value for "Please write down any behavior specific to the child that may help a parent identify him/her later on such as child's games, and main interests or specific things he/she likes to do" on the show page with the value of "Child games, Main Interest"
    And I should see a value for "Are there any clothes and belongings the child was found with?" on the show page with the value of "Yes"
    And I should see a value for "Please describe in detail how the child was found or taken in the family/children's center" on the show page with the value of "Details about how the child was found in the family center."
