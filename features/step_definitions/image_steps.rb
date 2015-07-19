Given /^the environment variable "([^"]*)" is set$/ do |variable_name|
  if ENV[variable_name].nil?
    fail "You must set the #{variable_name} environment variable to run the tests."
  end
end
