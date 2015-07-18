require "fileutils"


class Provisional::Init

  attr_reader :global_options

  def initialize(global_options)
    @global_options = global_options
  end

  def run
    create_config_file
  end

private

  def create_config_file
    FileUtils.mkdir_p(config_file_directory)
    FileUtils.copy(default_config_file, config_file) unless File.exist?(config_file)
  end

  def config_file
    global_options["config-file"]
  end

  def config_file_directory
    File.dirname(config_file)
  end

  def default_config_file
    File.expand_path('../../../data/default_config_file.yml', __FILE__)
  end

end
