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
    print "Building server '#{name}' from image '#{image.slug || image.name}'."
    $stdout.flush
    while find(id: server.id).status == "new"
      putc(".")
      $stdout.flush
      sleep 5
    end
    puts "DONE"
    # Have to re-get the server, so it's populated with its IP address.
    find(id: server.id)
  end

  def self.find(options = {})
    raise "Must pass in a hash" unless options.is_a?(Hash)
    if options[:id]
      Provisional.digital_ocean.droplets.find(id: options[:id])
    elsif options[:name]
      all.select{|server| server.name == options[:name]}.first
    end
  end

  def self.stop(server)
    return unless server
    action = Provisional.digital_ocean.droplet_actions.shutdown(droplet_id: server.id)
    action_id = action.id
    print "Stopping server '#{server.name}' (action_id = #{action_id})."
    until action.status == "completed" do
      putc(".")
      # $stdout.flush
      sleep 1
      action = Provisional.digital_ocean.actions.find(id: action_id)
    end
    # TODO: I've seen a shutdown not work, so we'll need a timeout.
    until Provisional.digital_ocean.droplets.find(id: server.id).status == "off" do
      putc(".")
      $stdout.flush
      sleep 1
    end
    puts "DONE"
  end


  def self.delete(server)
    return unless server
    Provisional.digital_ocean.droplets.delete(id: server.id)
    # Don't really need to wait for this operation to complete.
  end

private

  def self.all_ssh_keys
    Provisional.digital_ocean.ssh_keys.all.to_a.map(&:id)
  end

end
