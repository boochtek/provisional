DISTRO_IMAGES = %w[debian-8-x64 ubuntu-14-04-x64 coreos-beta]
APP_IMAGES = %w[joomla wordpress]


Given /^the environment variable "([^"]*)" is set$/ do |variable_name|
  if ENV[variable_name].nil?
    fail "You must set the #{variable_name} environment variable to run the tests."
  end
end

Given /^the default config file$/ do
  write_file(Provisional::CONFIG_FILE, File.read(Provisional::DEFAULT_CONFIG_FILE))
end

Then(/^the output should include the distributions images$/) do
  DISTRO_IMAGES.each do |image_name|
    assert_partial_output(image_name, all_output)
  end
end

Then(/^the output should not include any application images$/) do
  APP_IMAGES.each do |image_name|
    assert_no_partial_output(image_name, all_output)
  end
end
