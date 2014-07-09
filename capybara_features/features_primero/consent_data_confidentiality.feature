# JIRA PRIMERO-110
# JIRA PRIMERO-232
# JIRA PRIMERO-239

@javascript @primero
Feature: Consent Data Confidentiality
  As a Social Worker, I want to enter details about data confidentiality so that we can record
  the child's (individual's) wishes with respect to sharing information.

  Scenario: As a logged in user, I create a case details about data confidentiality
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "cases page"
    And I press the "Create a New Case" button
    And I press the "Data Confidentiality" button
    When I select "Child" from "Consent Obtained From"
    And I select "Yes" for "Consent has been obtained for the child to receive services" radio button
    And I select "Yes" for "Consent is given share non-identifiable information for reporting" radio button
    And I select "Yes" for "Consent has been obtained to disclose information for tracing purposes" radio button
    And I choose from "Consent has been given to share the information collected with":
      |  Family                |
      |  Caregiver             |
    And I fill in "If information can be shared with others, please specify who" with "N/A"
    And I fill in "What information should be withheld from a particular person or individual" with "None"
    And I choose from "Reason for withholding information":
      |  Fear of harm to themselves or others    |
      |  Other reason, please specific           |
    And I fill in "If other reason for withholding information, please specify" with "Other reason"
    And I select "Yes" for "Consent to Release Information to Security Services" radio button
    And I select "No" for "Consent to Release Information to Psychosocial Services" radio button
    And I select "Yes" for "Consent to Release Information to Health/Medical Services" radio button
    And I select "No" for "Consent to Release Information to Safe House/Shelter" radio button
    And I select "Yes" for "Consent to Release Information to Legal Assistance Services" radio button
    And I select "Yes" for "Consent to Release Information to Protection Services" radio button
    And I select "No" for "Consent to Release Information Livelihoods Services" radio button
    And I select "Yes" for "Consent to Release Information to Other Services" radio button
    And I fill in "If other services, please specify" with "N/A"
    And I press "Save"
    Then I should see "Case record successfully created" on the page
    When I press the "Data Confidentiality" button
    Then I should see a value for "Consent Obtained From" on the show page with the value of "Child"
    And I should see a value for "Consent has been obtained for the child to receive services" on the show page with the value of "Yes"
    And I should see a value for "Consent Obtained From" on the show page with the value of "Child"
    And I should see a value for "Consent has been obtained for the child to receive services" on the show page with the value of "Yes"
    And I should see a value for "Consent is given share non-identifiable information for reporting" on the show page with the value of "Yes"
    And I should see a value for "Consent has been obtained to disclose information for tracing purposes" on the show page with the value of "Yes"
    And I should see a value for "Consent has been given to share the information collected with" on the show page with the value of "Family, Caregiver"
    And I should see a value for "If information can be shared with others, please specify who" on the show page with the value of "N/A"
    And I should see a value for "What information should be withheld from a particular person or individual" on the show page with the value of "None"
    And I should see a value for "Reason for withholding information" on the show page with the value of "Fear of harm to themselves or others, Other reason, please specific"
    And I should see a value for "If other reason for withholding information, please specify" on the show page with the value of "Other reason"
    And I should see a value for "Consent to Release Information to Security Services" on the show page with the value of "Yes"
    And I should see a value for "Consent to Release Information to Psychosocial Services" on the show page with the value of "No"
    And I should see a value for "Consent to Release Information to Health/Medical Services" on the show page with the value of "Yes"
    And I should see a value for "Consent to Release Information to Safe House/Shelter" on the show page with the value of "No"
    And I should see a value for "Consent to Release Information to Legal Assistance Services" on the show page with the value of "Yes"
    And I should see a value for "Consent to Release Information to Protection Services" on the show page with the value of "Yes"
    And I should see a value for "Consent to Release Information Livelihoods Services" on the show page with the value of "No"
    And I should see a value for "Consent to Release Information to Other Services" on the show page with the value of "Yes"
    And I should see a value for "If other services, please specify" on the show page with the value of "N/A"
