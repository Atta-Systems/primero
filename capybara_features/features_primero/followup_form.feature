#JIRA PRIMERO-166
#JIRA PRIMERO-203
#JIRA PRIMERO-220
# JIRA PRIMERO-232

@javascript @primero
Feature: Followup
  As a Social worker, I want to enter information related to follow up visits so that we can report on our interactions with the child (individual) in our care.

  Background:
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "cases page"
    And I press the "Create a New Case" button
    And I press the "Follow Up" button

  Scenario: I am a logged in Social Worker on the Follow Ups form
    And I fill in the 1st "Followup Subform Section" subform with the follow:
      | Followup needed by                                          | 12/Jun/2014                                             |
      | Followup date                                               | 12/Jun/2014                                             |
      | Details about action taken                                  | Some details about action taken                         |
      | Date action taken?                                          | 10/Jun/2014                                             |
      | If yes, when do you recommend the next visit to take place? | The next week                                           |
      | Comments                                                    | Some comments                                           |
      | Type of followup                                            |<Select> Follow up After Reunification                   |
      | Type of service                                             |<Select> Health/Medical Service                          |
      | Type of assessment                                          |<Select> Medical Intervention Assessment                 |
      | Was the child/adult seen during the visit?                  |<Radio> No                                               |
      | If not, why?                                                |<Checkbox> At School                                     |
      | Has action been taken?                                      |<Radio> Yes                                              |
      | Is there a need for further follow-up visits?               |<Radio> Yes                                              |
    And I fill in the 2nd "Followup Subform Section" subform with the follow:
      | Followup needed by                                          | 15/Jun/2014                                             |
      | Followup date                                               | 15/Jun/2014                                             |
      | Details about action taken                                  | Some details about action taken                         |
      | Date action taken?                                          | 14/Jun/2014                                             |
      | Comments                                                    | Some additional comments                                |
      | Type of followup                                            | <Select> Follow up for Assessment                       |
      | Type of service                                             | <Select> Family Reunification Service                   |
      | Type of assessment                                          | <Select> Personal Intervention Assessment               |
      | Was the child/adult seen during the visit?                  | <Radio> No                                              |
      | If not, why?                                                | <Checkbox> Visiting Friends/Relatives                   |
      | Has action been taken?                                      | <Radio> Yes                                             |
      | Is there a need for further follow-up visits?               | <Radio> No                                              |
      | If not, do you recommend that the case be close?            | <Radio> Yes                                             |
    And I press "Save"
    Then I should see "Case record successfully created" on the page
    And I should see in the 1st "Follow Up" subform with the follow:
      | Followup needed by                                          | 12/Jun/2014                      |
      | Followup date                                               | 12/Jun/2014                      |
      | Details about action taken                                  | Some details about action taken  |
      | Date action taken?                                          | 10/Jun/2014                      |
      | If yes, when do you recommend the next visit to take place? | The next week                    |
      | Comments                                                    | Some comments                    |
      | Type of followup                                            | Follow up After Reunification    |
      | Type of service                                             | Health/Medical Service           |
      | Type of assessment                                          | Medical Intervention Assessment  |
      | Was the child/adult seen during the visit?                  | No                               |
      | If not, why?                                                | At School                        |
      | Has action been taken?                                      | Yes                              |
      | Is there a need for further follow-up visits?               | Yes                              |
    And I should see in the 2nd "Follow Up" subform with the follow:
      | Followup needed by                                          | 15/Jun/2014                      |
      | Followup date                                               | 15/Jun/2014                      |
      | Details about action taken                                  | Some details about action taken  |
      | Date action taken?                                          | 14/Jun/2014                      |
      | Comments                                                    | Some additional comments         |
      | Type of followup                                            | Follow up for Assessment         |
      | Type of service                                             | Family Reunification Service     |
      | Type of assessment                                          | Personal Intervention Assessment |
      | Was the child/adult seen during the visit?                  | No                               |
      | If not, why?                                                | Visiting Friends/Relatives       |
      | Has action been taken?                                      | Yes                              |
      | Is there a need for further follow-up visits?               | No                               |
      | If not, do you recommend that the case be close?            | Yes                              |
    And I press the "Edit" button
    And I press the "Follow Up" button
    And I remove the 2nd "Followup Subform Section" subform
    And I click OK in the browser popup
    And I fill in the following:
      | Followup needed by                                          | 11/Jun/2014                            |
      | Followup date                                               | 11/Jun/2014                            |
      | Details about action taken                                  | Some details about action taken        |
      | Date action taken?                                          | 10/Jun/2014                            |
      | If yes, when do you recommend the next visit to take place? | The next week                          |
      | Comments                                                    | Some comments                          |
    And I press "Save"
    And I should not see "Follow up for Assessment" on the page
    And I should not see "Personal Intervention Assessment" on the page
    And I should not see "15/Jun/2014" on the page
    And I should not see "14/Jun/2014" on the page
    And I should not see "Some additional comments" on the page
    And I should not see "Visiting Friends/Relatives" on the page
