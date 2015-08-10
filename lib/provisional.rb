require "provisional/version"
require "provisional/init"
require "provisional/image_operations"
require "yaml"
require "erb"


module Provisional

  CONFIG_FILE = "config/infrastructure/provisional.yml"
  DEFAULT_CONFIG_FILE = File.expand_path('../../data/default_config_file.yml', __FILE__)

  def self.config
    @config ||= YAML.load(ERB.new(File.read(CONFIG_FILE)).result)
  end

  def self.digital_ocean
    @digital_ocean ||= DropletKit::Client.new(access_token: digital_ocean_api_key)
  end

private

  def self.digital_ocean_api_key
    @digital_ocean_api_key ||= Provisional.config["vps"]["api_key"]
  end

end
