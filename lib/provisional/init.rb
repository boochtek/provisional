require "fileutils"


class Provisional::Init

  attr_reader :options

  def initialize(options)
    @options = options
  end

  def run
    create_config_file
  end

private

  def create_config_file
    FileUtils.mkdir_p(config_file_directory)
    FileUtils.copy(Provisional::DEFAULT_CONFIG_FILE, config_file) unless File.exist?(config_file)
  end

  def config_file
    options["config-file"]
  end

  def config_file_directory
    File.dirname(config_file)
  end

end
