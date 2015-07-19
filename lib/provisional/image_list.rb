require "droplet_kit"


class Provisional::ImageList

  attr_reader :options

  def initialize(options)
    @options = options
  end

  def run
    os_images.each do |image|
      display(image)
    end
    custom_images.each do |image|
      display(image)
    end
  end

private

  def digital_ocean
    @digital_ocean ||= DropletKit::Client.new(access_token: digital_ocean_api_key)
  end

  def digital_ocean_api_key
    @digital_ocean_api_key ||= Provisional.config["vps"]["api_key"]
  end

  def os_images
    @os_images ||= all_images.select{|image| image.public}.select{|image| image.slug =~ /-\d/ || image.slug =~ /coreos/ }
  end

  def custom_images
    @custom_images ||= all_images.select{|image| !image.public && image.name =~ /-\d{14}$/}
  end

  def all_images
    @all_images ||= digital_ocean.images.all.select{|image| image.type == "snapshot"}
  end

  def display(image)
    if image.public
      puts "#{image.slug}: #{image.distribution} #{image.name}"
    else
      puts "#{image.name}"
    end
  end

end
