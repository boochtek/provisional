require "provisional"


Given(/no deployment to "([^"]*)" has happened yet/) do |environment|
  server_list_for(environment).each do |server_name|
    server = Provisional::Server.find(name: server_name)
    Provisional::Server.delete(server)
  end
end


Then(/^there should be (\d+) "([^"]*)" servers? in "([^"]*)" for "([^"]*)"$/) do |count, server_type, environment, domain|
  count = count.to_i
  domain = domain.gsub(".", "\\.")
  matching_servers = server_list_for(environment).select{|server| server =~ /#{server_type}\d+\.#{environment}/}
  expect(matching_servers.size).to eq(count)
end


def server_list_for(environment)
  # %x(provisional server list #{environment}).split("\n")
  Provisional::Server.list(environment)
end
