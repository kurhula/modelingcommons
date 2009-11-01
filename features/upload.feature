Feature: Upload model

As a user,
I want to upload my model
So that other people can interact with it

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"

  Scenario: A user should see the upload form
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the upload page
    Then I should see "Upload a NetLogo model"

  Scenario: A user without any groups should not see "Set the Group"
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the upload page
    Then I should not see "Optional: Set the group"

  Scenario: A user may not upload an empty model
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the upload page
     And I press "Upload model"
    Then I should see "Sorry, but you must enter a model name and file."

  Scenario: A user may upload a poorly formed model
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the upload page
     And I attach a model file
     And I press "Upload model"
    Then I should see "Sorry, but you must enter a model name and file."
