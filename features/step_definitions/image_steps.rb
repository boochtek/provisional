Given /^the environment variable "([^"]*)" is set$/ do |variable_name|
  if ENV[variable_name].nil?
    fail "You must set the #{variable_name} environment variable to run the tests."
  end
end

Given /^the default config file$/ do
  write_file(Provisional::CONFIG_FILE, File.read(Provisional::DEFAULT_CONFIG_FILE))
end
