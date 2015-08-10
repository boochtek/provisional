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

Given(/^a file named "([^"]*)" in the "([^"]*)" image file directory$/) do |file_name, image_name|
  file_path = "#{Provisional::CONFIG_DIRECTORY}/#{image_name}/files/#{file_name}"
  file_contents = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
  write_file(file_path, file_contents)
end

Given(/^a script in the "([^"]*)" image script directory$/) do |image_name|
  file_path = "#{Provisional::CONFIG_DIRECTORY}/#{image_name}/scripts/create_file.sh"
  @file_to_add_through_script = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
  file_contents = <<"EOF"
#!/bin/bash
touch /var/tmp/#{@file_to_add_through_script}
EOF
  write_file(file_path, file_contents)
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
  expect(new_images.size).to be(1)
  expect(new_images.first).to include(image_name)
end

Then(/^the "([^"]*)" image should have a file named "([^"]*)" in "([^"]*)"$/) do |image_name, file_name, directory_name|
  server = build_server_from_image(image_name)
  ip_address = server.public_ip
  Provisional::ImageOperations.new.wait_until_ssh_responds(ip_address)
  directory_listing = %x(ssh #{Provisional::ImageOperations::SSH_OPTIONS} root@#{ip_address} "ls -1 #{directory_name}/").split("\n")
  expect(directory_listing).to include(file_name)
  Provisional::ImageOperations.new.stop_server(server.id)
  Provisional::ImageOperations.new.delete_server(server.id)
end

Then(/^the script should have run on the "([^"]*)" image$/) do |image_name|
  server = build_server_from_image(image_name)
  ip_address = server.public_ip
  Provisional::ImageOperations.new.wait_until_ssh_responds(ip_address)
  directory_name = "/var/tmp"
  directory_listing = %x(ssh #{Provisional::ImageOperations::SSH_OPTIONS} root@#{ip_address} "ls -1 #{directory_name}/").split("\n")
  expect(directory_listing).to include(@file_to_add_through_script)
  Provisional::ImageOperations.new.stop_server(server.id)
  Provisional::ImageOperations.new.delete_server(server.id)
end


def custom_images
  image_list.grep(/-\d{14}$/)
end

def custom_image
  images = custom_images
  fail "Expected a single custom image" unless images.size == 1
  images.first
end

def image_list
  %x(provisional image list).split("\n")
end

def new_images
  image_list - @original_image_list
end

def build_server_from_image(image_name)
  latest_image_name = Provisional::ImageOperations.new.custom_images.map(&:name).grep(/^#{image_name}-/).sort.last
  server_name = "#{image_name}-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"
  server_id = Provisional::ImageOperations.new.build_server(server_name, latest_image_name)
  server = Provisional.digital_ocean.droplets.find(id: server_id)
end
