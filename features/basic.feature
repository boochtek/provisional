Feature: Basic functionality


Scenario: It runs
    When I run `provisional --version`
    Then the output should contain "provisional"
    And the output should contain the version number
    And the exit status should be 0


Scenario: Init creates a config file
    Given I have no config file
    When I run `provisional init`
    Then a config file should be generated


Scenario: Init does not overwrite an existing config file
    Given I already have a config file
    When I run `provisional init`
    Then my config file should be unchanged
