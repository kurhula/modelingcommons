Feature: Browse models

As a user,
I want to browse through a model
To learn, as well as share and collaborate with others

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And a NetLogo model named "Test model"

  Scenario: A user should be able to view the model page without logging in
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the model page for "Test model"
    Then I should see "Test model"

  Scenario: A user should be able to view the model page with logging in
    When I go to the model page for "Test model"
    Then I should see "Test model"

  Scenario Outline: Try each of the tabs for the model when not logged in
    When I go to the "<tab_name>" tab for "Test model"
    Then I should see "<string_to_find>"

  Scenarios: Different tabs
    | tab_name    | string_to_find                              |
    | discuss     | Return to page for the 'Test model' model   |
    | applet      | Return to page for the 'Test model' model   |
    | info        | Return to page for the 'Test model' model   |
    | procedures  | Return to page for the 'Test model' model   |
    | history     | Return to page for the 'Test model' model   |
    | tags        | Return to page for the 'Test model' model   |
    | related     | Return to page for the 'Test model' model   |
    | upload      | Return to page for the 'Test model' model   |
    | permissions | Return to page for the 'Test model' model   |

  Scenario Outline: Try each of the tabs for the model when I am logged in
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "<tab_name>" tab for "Test model"
    Then I should see "Return to page for the 'Test model' model"

  Scenarios: Different tabs
    | tab_name    |
    | discuss     |
    | applet      |
    | info        |
    | procedures  |
    | history     |
    | tags        |
    | related     |
    | upload      |
    | permissions |

  Scenario: A user should be able to recommend a model
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the model page for "Test model"
     And I follow "Recommend"
    Then I should see "Added your recommendation."
     And I should see "1 recommendation to date"

  Scenario: A user should be able to see the list of recommenders
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the model page for "Test model"
     And I follow "Recommend"
     And I follow "1 recommendation"
    Then I should see "Recommendations for Test model"
     And I should see "You recommended it"

  Scenario: A user should be able to flag a model as spam
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the model page for "Test model"
     And I follow "Report as spam"
    Then I should see "Thanks for letting us know about this possible spam!"
     And I should see "1 person marked it as spam"

  Scenario: A user should be able to download the model
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the model page for "Test model"
     And I follow "Download"
    Then the response should be of type "application/zip"
     And the response should be successful

  Scenario: A user should be able to go to a random model
    When I go to the list-models page
     And I follow "Jump to a random model"
    Then I should be on the model page for "Test model"

  Scenario: A user should be able to set permissions
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "permissions" tab for "Test model"
     And I choose "Only you may see this model"
     And I choose "Only you may modify this model"
     And I press "Set permissions"
     And I go to the model page for "Test model"
    Then I should see "Successfully set permissions."
    Then I should see "Visible by No one but yourself"
    Then I should see "Changeable by No one but yourself"
