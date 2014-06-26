# JIRA PRIMERO-134

@javascript @primero
Feature: Tracing Reunification Details
  As a Social Worker I want to enter information related to reunification
  so that we can record the status of the child in the reunification process.

  Background:
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "cases page"
    And I press the "Create a New Case" button
    And I press the "Tracing" button

  Scenario: As a logged in user, I should access the form section tracing and create reunification details
    And I fill in the 1st "Reunification Details Section" subform with the follow:
      | Name of adult child was reunified with               | Verma Webol               |
      | Relationship of adult to child                       | Father                    |
      | Address                                              | Test Village 2            |
      | Location of adult with whom the child was reunified  | 124 C.Ave                 |
      | Address where the reunification is taking place      | 125 B.Ave                 |
      | Location where the reunifcation is taking place      | Kenya                     |
      | What type of reunification                           | <Select> Mass Tracing     |
      | Date of reunification                                | 31-May-2014               |
      | Was the child reunified with the verfified adult?    | <Select> No               |
      | If not, what was the reason for the change?          | <Select> Change of Mind   |
      | Is there a need for follow up?                       | <Select> Yes              |

    And I fill in the 2nd "Reunification Details Section" subform with the follow:
      | Name of adult child was reunified with               | Vivian Nelson             |
      | Relationship of adult to child                       | Mother                    |
      | Address                                              | Test Village              |
      | Location of adult with whom the child was reunified  | 123 C.Ave                 |
      | Address where the reunification is taking place      | 123 B.Ave                 |
      | Location where the reunifcation is taking place      | Kenya                     |
      | What type of reunification?                          | <Select> Mass Tracing     |
      | Date of reunification                                | 30-May-2014               |
      | Was the child reunified with the verfified adult?    | <Select> Yes              |
      | If not, what was the reason for the change?          | <Select> Not Applicable   |
      | Is there a need for follow up?                       | <Select> No               |
    And I press "Save"
    Then I should see "Case record successfully created" on the page
    And I press the "Tracing" button
    And I should see a value for "Name of adult child was reunified with" on the show page with the value of "Verma Webol"
    And I should see a value for "Relationship of adult to child" on the show page with the value of "Father"
    And I should see a value for "Address" on the show page with the value of "Test Village 2"
    And I should see a value for "Location of adult with whom the child was reunified" on the show page with the value of "124 C.Ave"
    And I should see a value for "Address where the reunification is taking place" on the show page with the value of "125 B.Ave"
    And I should see a value for "Location where the reunifcation is taking place" on the show page with the value of "Kenya"
    And I should see a value for "What type of reunification?" on the show page with the value of "Mass Tracing"
    And I should see a value for "Date of reunification" on the show page with the value of "31-May-2014"
    And I should see a value for "Was the child reunified with the verfified adult?" on the show page with the value of "No"
    And I should see a value for "If not, what was the reason for the change?" on the show page with the value of "Change of Mind"
    And I should see a value for "Is there a need for follow up?" on the show page with the value of "Yes"

  Scenario: As a logged in user, I should access the form section tracing and add/remove reunification details
    And I fill in the 1st "Reunification Details Section" subform with the follow:
      | Name of adult child was reunified with               | Vivian Nelson             |
      | Relationship of adult to child                       | Mother                    |
      | Address                                              | Test Village              |
      | Location of adult with whom the child was reunified  | 123 C.Ave                 |
      | Address where the reunification is taking place      | 123 B.Ave                 |
      | Location where the reunifcation is taking place      | Kenya                     |
      | What type of reunification?                          | <Select> Mass Tracing     |
      | Date of reunification                                | 30-May-2014               |
      | Was the child reunified with the verfified adult?    | <Select> Yes              |
      | If not, what was the reason for the change?          | <Select> Not Applicable   |
      | Is there a need for follow up?                       | <Select> No               |
    And I fill in the 2nd "Reunification Details Section" subform with the follow:
      | Name of adult child was reunified with               | Verma Webol               |
      | Relationship of adult to child                       | Father                    |
      | Address                                              | Test Village 2            |
      | Location of adult with whom the child was reunified  | 124 C.Ave                 |
      | Address where the reunification is taking place      | 125 B.Ave                 |
      | Location where the reunifcation is taking place      | Kenya                     |
      | What type of reunification?                          | <Select> Mass Tracing     |
      | Date of reunification                                | 31-May-2014               |
      | Was the child reunified with the verfified adult?    | <Select> No               |
      | If not, what was the reason for the change?          | <Select> Change of Mind   |
      | Is there a need for follow up?                       | <Select> Yes              |
    And I press "Save"
    Then I should see "Case record successfully created" on the page
    And I press the "Edit" button
    And I remove the 1st "Reunification Details Section" subform
    And I click OK in the browser popup
    And I fill in the 3rd "Reunification Details Section" subform with the follow:
      | Name of adult child was reunified with               | Mavin Martian             |
      | Relationship of adult to child                       | Father                    |
      | Address                                              | Test Village 3            |
      | Location of adult with whom the child was reunified  | 123 E.Ave                 |
      | Address where the reunification is taking place      | 123 G.Ave                 |
      | Location where the reunifcation is taking place      | Kenya                     |
      | What type of reunification?                          | <Select> Mass Tracing     |
      | Date of reunification                                | 29-May-2014               |
      | Was the child reunified with the verfified adult?    | <Select> Yes              |
      | If not, what was the reason for the change?          | <Select> Not Applicable   |
      | Is there a need for follow up?                       | <Select> No               |
    And I press "Save"
    Then I should not see "Vivian Nelson" on the page
    And I should see "Verma Webol" on the page
    And I should see "Marvin Martian" on the page