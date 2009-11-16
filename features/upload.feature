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

  Scenario: A user may upload a valid model file
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the upload page
     And I fill in "New Model" for "new_model_name"
     And I attach a model file
     And I press "Upload model"
    Then I should see "Thanks for uploading the new model called 'New Model'."

  Scenario: A user may upload a valid model file with individual permissions
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the upload page
     And I fill in "New Model" for "new_model_name"
     And I choose "Only you may see this model."
     And I choose "Only you may modify this model."
     And I attach a model file
     And I press "Upload model"
     And I follow "New Model model's page"
    Then I should see "Visible by No one but yourself"
    Then I should see "Changeable by No one but yourself"

  Scenario: A user may upload a valid model file with group permissions, but no group, thus giving owner permissions
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the upload page
     And I fill in "New Model" for "new_model_name"
     And I choose "Only you may see this model."
     And I choose "Only you may modify this model."
     And I attach a model file
     And I press "Upload model"
     And I follow "New Model model's page"
    Then I should see "Visible by No one but yourself"
    Then I should see "Changeable by No one but yourself"

  Scenario: A user may upload a valid model file with universal permissions
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the upload page
     And I fill in "New Model" for "new_model_name"
     And I choose "Everyone can see this model."
     And I choose "Everyone can modify this model."
     And I attach a model file
     And I press "Upload model"
     And I follow "New Model model's page"
    Then I should see "Visible by Everyone"
    Then I should see "Changeable by Everyone"

  Scenario: A user may upload a valid model file with a preview
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the upload page
     And I fill in "New Model" for "new_model_name"
     And I attach a model file
     And I attach a preview image
     And I press "Upload model"
    Then I should see "Thanks for uploading the new model called 'New Model'."
     And I should see "The preview image was also saved."
