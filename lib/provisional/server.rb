require "droplet_kit"


class Provisional::Server

  def self.list(environment)
    all.map(&:name)
  end

  def self.all(environment = nil)
    # TODO: Filter by environment (and domain), if given.
    Provisional.digital_ocean.droplets.all.to_a
  end

  def self.create(options = {})
    raise "Must pass in a hash" unless options.is_a?(Hash)
    name = options[:name]
    image = options[:image]
    server_options = { region: 'nyc3', size: '512mb', ssh_keys: all_ssh_keys }
    droplet = DropletKit::Droplet.new({name: name, image: image.id}.merge(server_options))
    server = Provisional.digital_ocean.droplets.create(droplet)
    print "Building server '#{name}' from image '#{image.name}'."
    $stdout.flush
    while find(id: server.id).status == "new"
      putc(".")
      $stdout.flush
      sleep 5
    end
    puts "DONE"
    return server
  end

  def self.find(options = {})
    raise "Must pass in a hash" unless options.is_a?(Hash)
    if options[:id]
      Provisional.digital_ocean.droplets.find(id: options[:id])
    elsif options[:name]
      all.select{|server| server.name == options[:name]}
    end
  end

private

  def self.all_ssh_keys
    Provisional.digital_ocean.ssh_keys.all.to_a.map(&:id)
  end

end
