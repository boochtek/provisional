Feature: Basic functionality

Scenario: It runs

    When I run `provisional --version`
    Then the output should contain "Provisional"
    And the output should contain the version number
