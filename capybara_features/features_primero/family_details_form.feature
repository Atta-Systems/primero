#JIRA PRIMERO-97
#JIRA PRIMERO-222
#JIRA PRIMERO-228
#JIRA PRIMERO-232
#JIRA PRIMERO-240

@javascript @primero
Feature: Family Details Form
  As a Social worker, I want to enter the information related to the family details.

  Scenario: As a logged in user, I should access the form section family details subform
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "form section page"
    And I press the "Nested Family Details" button
    Then I should see the following fields:
      |Name|
      |How are they related to the child?|
      |Is this person the caregiver?|
      |Did the child live with this person before separation?|
      |Is the child in contact with this person?|
      |Is the child separated from this person?|
      |List any agency identifiers as a comma separated list|
      |Nickname|
      |Are they alive?|
      |If dead, please provide details|
      |Age|
      |Date of Birth|
      |Language|
      |Religion|
      |Ethnicity|
      |Sub Ethnicity 1|
      |Sub Ethnicity 2|
      |Nationality|
      |Comments|
      |Occupation|
      |Current Address|
      |Is this a permanent location?|
      |Current Location|
      |Last Known Address|
      |Last Known Location|
      |Telephone|
      |Other persons well known to the child|

  Scenario: As a logged in user, I should access the form section family details
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "form section page"
    And I press the "Family Details" button
    Then I should see the following fields:
      |Size of Family|
      |Notes about Family|
      |What is the child’s intended address?|
      |Family Details|

  Scenario: I create a case with family details information.
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "cases page"
    And I press the "Create a New Case" button
    And I press the "Family Details" button
    And I fill in the following:
      | Size of Family                        | 3                  |
      | Notes about Family                    | Some Family Notes  |
      | What is the child’s intended address? | Some Child Address |
    #Added Family Details
    And I fill in the 1st "Family Details Section" subform with the follow:
      |Name                                                  | Socorro                                    |
      |How are they related to the child?                    | <Select> Mother                            |
      |Is this person the caregiver?                         | <Radio> Yes                                |
      |Did the child live with this person before separation?| <Radio> Yes                                |
      |Is the child in contact with this person?             | <Radio> Yes                                |
      |Is the child separated from this person?              | <Radio> Yes                                |
      |List any agency identifiers as a comma separated list | Agency1 ,Agency 2                          |
      |Nickname                                              | Coco                                       |
      |Are they alive?                                       | <Select> Alive                             |
      |If dead, please provide details                       | No Dead Notes                              |
      |Age                                                   | 36                                         |
      |Date of Birth                                         | 21-May-1975                                |
      |Language                                              | <Choose>Language 1<Choose>Language 2       |
      |Religion                                              | <Choose>Religion 1<Choose>Religion 2       |
      |Ethnicity                                             | <Select> Ethnicity 1                       |
      |Sub Ethnicity 1                                       | <Select> Sub Ethnicity 1                   |
      |Sub Ethnicity 2                                       | <Select> Sub Ethnicity 2                   |
      |Nationality                                           | <Choose>Nationality 1<Choose>Nationality 2 |
      |Comments                                              | Some Comments About Coco                   |
      |Occupation                                            | Some Ocupation About Coco                  |
      |Current Address                                       | Coco's Current Address                     |
      |Is this a permanent location?                         | <Radio> Yes                                |
      |Current Location                                      | Coco's Current Location                    |
      |Last Known Address                                    | Coco's Last Known Address                  |
      |Last Known Location                                   | Coco's Last Known Location                 |
      |Telephone                                             | Coco's Telephone                           |
      |Other persons well known to the child                 | Pedro                                      |
    And I fill in the 2st "Family Details Section" subform with the follow:
      |Name                                                  | Pedro                                      |
      |How are they related to the child?                    | <Select> Father                            |
      |Is this person the caregiver?                         | <Radio> No                                 |
      |Did the child live with this person before separation?| <Radio> No                                 |
      |Is the child in contact with this person?             | <Radio> No                                 |
      |Is the child separated from this person?              | <Radio> No                                 |
      |List any agency identifiers as a comma separated list | Agency3 ,Agency 4                          |
      |Nickname                                              | Pepe                                       |
      |Are they alive?                                       | <Select> Unknown                           |
      |If dead, please provide details                       | Unknown Information                        |
      |Age                                                   | 37                                         |
      |Date of Birth                                         | 21-May-1974                                |
      |Language                                              | <Choose>Language 2                         |
      |Religion                                              | <Choose>Religion 2                         |
      |Ethnicity                                             | <Select> Ethnicity 2                       |
      |Sub Ethnicity 1                                       | <Select> Sub Ethnicity 2                   |
      |Sub Ethnicity 2                                       | <Select> Sub Ethnicity 1                   |
      |Nationality                                           | <Choose>Nationality 2                      |
      |Comments                                              | Some Comments About Pepe                   |
      |Occupation                                            | Some Ocupation About Pepe                  |
      |Current Address                                       | Pepe's Current Address                     |
      |Is this a permanent location?                         | <Radio> No                                 |
      |Current Location                                      | Pepe's Current Location                    |
      |Last Known Address                                    | Pepe's Last Known Address                  |
      |Last Known Location                                   | Pepe's Last Known Location                 |
      |Telephone                                             | Pepe's Telephone                           |
      |Other persons well known to the child                 | Juan                                       |
    And I press "Save"
    Then I should see "Case record successfully created" on the page
    And I should see a value for "Size of Family" on the show page with the value of "3"
    And I should see a value for "Notes about Family" on the show page with the value of "Some Family Notes"
    And I should see a value for "What is the child’s intended address?" on the show page with the value of "Some Child Address"
    #Verify values from the subform
    And I should see in the 1st "Family Detail" subform with the follow:
      |Name                                                  | Socorro                      |
      |How are they related to the child?                    | Mother                       |
      |Is this person the caregiver?                         | Yes                          |
      |Did the child live with this person before separation?| Yes                          |
      |Is the child in contact with this person?             | Yes                          |
      |Is the child separated from this person?              | Yes                          |
      |List any agency identifiers as a comma separated list | Agency1 ,Agency 2            |
      |Nickname                                              | Coco                         |
      |Are they alive?                                       | Alive                        |
      |If dead, please provide details                       | No Dead Notes                |
      |Age                                                   | 36                           |
      |Date of Birth                                         | 21-May-1975                  |
      |Language                                              | Language 1, Language 2       |
      |Religion                                              | Religion 1, Religion 2       |
      |Ethnicity                                             | Ethnicity 1                  |
      |Sub Ethnicity 1                                       | Sub Ethnicity 1              |
      |Sub Ethnicity 2                                       | Sub Ethnicity 2              |
      |Nationality                                           | Nationality 1, Nationality 2 |
      |Comments                                              | Some Comments About Coco     |
      |Occupation                                            | Some Ocupation About Coco    |
      |Current Address                                       | Coco's Current Address       |
      |Is this a permanent location?                         | Yes                          |
      |Current Location                                      | Coco's Current Location      |
      |Last Known Address                                    | Coco's Last Known Address    |
      |Last Known Location                                   | Coco's Last Known Location   |
      |Telephone                                             | Coco's Telephone             |
      |Other persons well known to the child                 | Pedro                        |
    And I should see in the 2nd "Family Detail" subform with the follow:
      |Name                                                  | Pedro                        |
      |How are they related to the child?                    | Father                       |
      |Is this person the caregiver?                         | No                           |
      |Did the child live with this person before separation?| No                           |
      |Is the child in contact with this person?             | No                           |
      |Is the child separated from this person?              | No                           |
      |List any agency identifiers as a comma separated list | Agency3 ,Agency 4            |
      |Nickname                                              | Pepe                         |
      |Are they alive?                                       | Unknown                      |
      |If dead, please provide details                       | Unknown Information          |
      |Age                                                   | 37                           |
      |Date of Birth                                         | 21-May-1974                  |
      |Language                                              | Language 2                   |
      |Religion                                              | Religion 2                   |
      |Ethnicity                                             | Ethnicity 2                  |
      |Sub Ethnicity 1                                       | Sub Ethnicity 2              |
      |Sub Ethnicity 2                                       | Sub Ethnicity 1              |
      |Nationality                                           | Nationality 2                |
      |Comments                                              | Some Comments About Pepe     |
      |Occupation                                            | Some Ocupation About Pepe    |
      |Current Address                                       | Pepe's Current Address       |
      |Is this a permanent location?                         | No                           |
      |Current Location                                      | Pepe's Current Location      |
      |Last Known Address                                    | Pepe's Last Known Address    |
      |Last Known Location                                   | Pepe's Last Known Location   |
      |Telephone                                             | Pepe's Telephone             |
      |Other persons well known to the child                 | Juan                         |
