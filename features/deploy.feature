Feature: Deploying


Background:
    Given the environment variable "DIGITAL_OCEAN_API_KEY" is set
    Given the environment variable "DOMAIN" is set to "testapp.example.com"
    Given the default config file


Scenario: Cold deploy
    Given no deployment to "staging" has happened yet
    # And images have been created for all the server types in "staging"
    When I run `provisional deploy --cold staging`
    Then the output should contain "Deploying all images to 'staging'."
    And there should be 1 "lb" server in "staging" for "testapp.example.com"
    And there should be 2 "app" servers in "staging" for "testapp.example.com"
    And there should be 1 "db" server in "staging" for "testapp.example.com"
