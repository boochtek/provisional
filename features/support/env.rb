require "bundler/setup"
require "aruba/cucumber"


# Provisioning can take a long time -- the 15-second default isn't even close to cutting it.
Aruba.configure do |config|
  config.exit_timeout = 600
end
