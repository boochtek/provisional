require "provisional/version"
require "provisional/init"
require "provisional/image_list"
require "yaml"
require "erb"


module Provisional

  CONFIG_FILE = "config/infrastructure/provisional.yml"
  DEFAULT_CONFIG_FILE = File.expand_path('../../data/default_config_file.yml', __FILE__)

  def self.config
    @config ||= YAML.load(ERB.new(File.read(CONFIG_FILE)).result)
  end

end
