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

Given /^I keep track of the image list$/ do
  @original_image_list = %x(provisional image list).split("\n")
  fail "Original image list is unexpectedly empty." if @original_image_list.empty?
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

Then /^there should be a new "([^"]*)" image$/ do |image_name|
  image_list = %x(provisional image list).split("\n")
  new_images = (image_list - @original_image_list)
  expect(new_images.size).to be(1)
  expect(new_images.first).to include(image_name)
end
