require "provisional"


CONFIG_FILE_CONTENT = "This is my config file"


Given /^the environment variable "([^"]*)" is set$/ do |variable_name|
  if ENV[variable_name].nil?
    fail "You must set the #{variable_name} environment variable to run the tests."
  end
end

Given(/^the environment variable "([^"]*)" is set to "([^"]*)"$/) do |variable_name, value|
  ENV[variable_name] = value
  %x[export #{variable_name}='#{value}']
end

Given /^the default config file$/ do
  write_file(Provisional::CONFIG_FILE, File.read(Provisional::DEFAULT_CONFIG_FILE))
end

Given /^I have no config file$/ do
  expect(Provisional::CONFIG_FILE).to_not be_an_existing_file
end

Given /^I already have a config file$/ do
  write_file(Provisional::CONFIG_FILE, CONFIG_FILE_CONTENT)
end

Then /^the output should contain the version number$/ do
  assert_partial_output(Provisional::VERSION, all_output)
end

Then /^a config file should be generated$/ do
  expect(Provisional::CONFIG_FILE).to be_an_existing_file
end

Then /^my config file should be unchanged$/ do
  expect(Provisional::CONFIG_FILE).to have_file_content(CONFIG_FILE_CONTENT)
  remove(Provisional::CONFIG_FILE)
end
