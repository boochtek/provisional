require "bundler/setup"
require "aruba/cucumber"


# Our provisioning takes a while -- the 15-second default won't cut it.
Aruba.configure do |config|
  config.exit_timeout = 300
end
