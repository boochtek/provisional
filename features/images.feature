Feature: Managing images


Background:
    Given the environment variable "DIGITAL_OCEAN_API_KEY" is set
    Given the default config file


Scenario: List images
    When I run `provisional image list`
    Then the output should include the distributions images
    But the output should not include any application images

Scenario: Create an image
    Given I keep track of the image list
    When I run `provisional image build base`
    Then the output should contain "Building"
    And the output should contain "from 'debian-8-x64'"
    And there should be a new "base" image
