#JIRA PRIMERO-296
#JIRA PRIMERO-324
#JIRA PRIMERO-352
#JIRA PRIMERO-363

@javascript @primero
Feature: Killing Form
  As a User, I want to capture the weapon type for killing or maiming violations so that information is recorded for reporting purposes

  Scenario: As a logged in user, I will create a incident for killing of children
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "incidents page"
    And I press the "Create a New Incident" button
    And I press the "Violations" button
    And I press the "Killing" button
    And I fill in the following:
      | Number of victims: boys                                                                     | 1                                      |
      | Number of victims: girls                                                                    | 2                                      |
      | Number of victims: unknown                                                                  | 3                                      |
      | Number of total victims                                                                     | 6                                      |
      | Method                                                                                      | <Select> Summary                       |
      | Cause                                                                                       | <Select> IED                           |
      | Details                                                                                     | Some details                           |
      | Circumstances                                                                               | <Select> Direct Attack                 |
      | Consequences                                                                                | <Select> Killing                       |
      | Context                                                                                     | <Select> Weapon Used Against The Child |
      | Mine Incident                                                                               | <Radio> No                             |
      | Was the victim/survivor directly participating in hostilities at the time of the violation? | <Select> Yes                           |
      | Did the violation occur during or as a direct result of abduction?                          | <Select> Yes                           |
    And I press "Save"
    Then I should see "Incident record successfully created" on the page
    And I should see 1 subform on the show page for "Killing"
    And I should see in the 1st "Killing" subform with the follow:
      | Number of victims: boys                                                                     | 1                             |
      | Number of victims: girls                                                                    | 2                             |
      | Number of victims: unknown                                                                  | 3                             |
      | Number of total victims                                                                     | 6                             |
      | Method                                                                                      | Summary                       |
      | Cause                                                                                       | IED                           |
      | Details                                                                                     | Some details                  |
      | Circumstances                                                                               | Direct Attack                 |
      | Consequences                                                                                | Killing                       |
      | Context                                                                                     | Weapon Used Against The Child |
      | Mine Incident                                                                               | No                            |
      | Was the victim/survivor directly participating in hostilities at the time of the violation? | Yes                           |
      | Did the violation occur during or as a direct result of abduction?                          | Yes                           |

