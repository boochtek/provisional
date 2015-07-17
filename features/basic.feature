Feature: Basic functionality


Scenario: It runs
    When I run `provisional --version`
    Then the output should contain "provisional"
    And the output should contain the version number
    And the exit status should be 0
