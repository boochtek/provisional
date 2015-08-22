require "droplet_kit"


class Provisional::Image

  def self.list
    all.map(&:name)
  end

  def self.all
    Provisional.digital_ocean.images.all.to_a # select{|image| image.type == "snapshot"}
  end

  def self.custom
    all.select{|image| !image.public && image.name =~ /-\d{14}$/}
  end

  def self.find(options)
    raise "Must pass in a hash" unless options.is_a?(Hash)
    if options[:id]
      Provisional.digital_ocean.images.find(id: id)
    elsif options[:name]
      name = options[:name]
      image = all.select{|image| image.slug == name || image.name == name}.first
      if image.nil?
        image = all.select{|image| image.name =~ /#{name}-\d{14}/}.sort.last
      end
      return image
    else
      raise "Don't know how to find image with that criteria"
    end
  end

  def self.create(options = {})
    raise "Must pass in a hash" unless options.is_a?(Hash)
    if options[:name] && options[:from]
      # Create a new image from a server.
    else
      raise "Don't know how to create image with that criteria"
    end
  end

end
