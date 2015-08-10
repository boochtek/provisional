Feature: Managing images


Background:
    Given the environment variable "DIGITAL_OCEAN_API_KEY" is set
    Given the default config file


Scenario: List images
    When I run `provisional image list`
    Then the output should include the distributions images
    But the output should not include any application images
