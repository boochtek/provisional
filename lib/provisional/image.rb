require "droplet_kit"


class Provisional::Image

  def self.list
    all.map(&:name)
  end

  def self.all
    Provisional.digital_ocean.images.all.select{|image| image.type == "snapshot"}
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
      if name =~ /-\d{14}/
        all.select{|image| image.name == name}.first
      else
        all.select{|image| image.name =~ /#{name}-\d{14}/}.sort.last
      end
    end
  end

  def self.create(options = {})
    raise "Must pass in a hash" unless options.is_a?(Hash)
    if options[:name] && options[:from]
      # Create a new image from a server.
    else
    end
  end

end
