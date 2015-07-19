Feature: Managing images


Background:
    Given the environment variable "DIGITAL_OCEAN_API_KEY" is set


Scenario: List images
    When I run `provisional image list`
    Then the output should contain "debian-8-x64"
    And the output should contain "ubuntu-14-10-x64"
    And the output should contain "coreos-beta"
    And the output should not contain "joomla"
    And the output should not contain "wordpress"
