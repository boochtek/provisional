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
    unless File.exist?(config_file_directory)
      FileUtils.mkdir_p(config_file_directory_parent)
      FileUtils.copy_entry(Provisional::DEFAULT_CONFIG, config_file_directory_parent)
    end
  end

  def config_file
    options["config-file"]
  end

  def config_file_directory
    File.dirname(config_file)
  end

  def config_file_directory_parent
    File.dirname(config_file_directory)
  end

end
