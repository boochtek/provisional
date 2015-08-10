require "droplet_kit"


class Provisional::ImageOperations

  SSH_OPTIONS = "-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o CheckHostIP=no"

  attr_reader :options

  def initialize(options = {})
    @options = options
  end

  def list
    os_images.each do |image|
      display(image)
    end
    custom_images.each do |image|
      display(image)
    end
  end

  def build(image_name)
    base_image = base_image_for(image_name)
    name = "#{image_name}-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"
    server_id = build_server(name, base_image)
    transfer_files_to_server(image_name, server_id)
    # run_scripts_on_server(name)
    stop_server(server_id)
    build_image_from_server(name, server_id)
    delete_server(server_id)
  end

  def transfer_files_to_server(image_name, server_id)
    server = Provisional.digital_ocean.droplets.find(id: server_id)
    ip_address = server.public_ip
    wait_until_ssh_responds(ip_address)
    %x(ssh #{SSH_OPTIONS} root@#{ip_address} mkdir -p /var/tmp/provisional)
    %x(scp #{SSH_OPTIONS} -r #{Provisional::CONFIG_DIRECTORY}/#{image_name}/files/ root@#{ip_address}:/var/tmp/provisional/files/)
    %x(scp #{SSH_OPTIONS} -r #{Provisional::CONFIG_DIRECTORY}/#{image_name}/scripts/ root@#{ip_address}:/var/tmp/provisional/scripts/)
  end

  def wait_until_ssh_responds(ip_address)
    until %x(ssh #{SSH_OPTIONS} root@#{ip_address} "ls -d1 /") == "/\n"
      puts "Waiting for SSH on #{ip_address} to respond"
      sleep 1
    end
  end

  def stop_server(id)
    action = Provisional.digital_ocean.droplet_actions.shutdown(droplet_id: id)
    action_id = action.id
    print "Stopping server '#{id}' (action_id = #{action_id})."
    until action.status == "completed" do
      putc(".")
      # $stdout.flush
      sleep 1
      action = Provisional.digital_ocean.actions.find(id: action_id)
    end
    # TODO: I've seen a shotdown not work, so we'll need a timeout.
    until Provisional.digital_ocean.droplets.find(id: id).status == "off" do
      putc(".")
      $stdout.flush
      sleep 1
    end
    puts "DONE"
  end

  def build_image_from_server(name, id)
    action = Provisional.digital_ocean.droplet_actions.snapshot(droplet_id: id, name: name)
    if action.is_a?(Hash) && action.has_key?("message")
      raise "Error building image: #{message}"
    end
    action_id = action.id
    print "Building '#{name}' image from server '#{id}'."
    until Provisional.digital_ocean.actions.find(id: action_id).status == "completed"
      putc(".")
      $stdout.flush
      sleep 5
    end
    puts "DONE"
  end

  def delete_server(id)
    Provisional.digital_ocean.droplets.delete(id: id)
    # Don't really need to wait for this one to complete.
  end

  def build_server(server_name, base_image_name)
    # TODO: Need to better figure out how to handle region, size, and other options.
    begin
      droplet = DropletKit::Droplet.new(name: server_name, image: base_image_name, region: 'nyc3', size: '512mb', ssh_keys: all_ssh_keys)
      created = Provisional.digital_ocean.droplets.create(droplet)
    rescue DropletKit::FailedCreate
      base_image_id = Provisional.digital_ocean.images.all.to_a.select{|image| image.name == base_image_name}.first.id
      droplet = DropletKit::Droplet.new(name: server_name, image: base_image_id, region: 'nyc3', size: '512mb', ssh_keys: all_ssh_keys)
      created = Provisional.digital_ocean.droplets.create(droplet)
    end
    created_id = created.id
    print "Building server '#{server_name}' from image '#{base_image_name}'."
    $stdout.flush
    while Provisional.digital_ocean.droplets.find(id: created_id).status == "new"
      putc(".")
      $stdout.flush
      sleep 5
    end
    puts "DONE"
    return created_id
  end

  def custom_images
    @custom_images ||= all_images.select{|image| !image.public && image.name =~ /-\d{14}$/}
  end

private

  def os_images
    @os_images ||= all_images.select{|image| image.public}.select{|image| image.slug =~ /-\d/ || image.slug =~ /coreos/ }
  end

  def base_image_for(image_name)
    image_config_for(image_name)["base-image"]
  end

  def image_config_for(image_name)
    Provisional.config["images"][image_name] or raise "No config file section for image '#{image_name}'"
  end

  def all_images
    @all_images ||= Provisional.digital_ocean.images.all.select{|image| image.type == "snapshot"}
  end

  def all_ssh_keys
    Provisional.digital_ocean.ssh_keys.all.to_a.map(&:id)
  end

  def display(image)
    if image.public
      puts "#{image.slug}: #{image.distribution} #{image.name}"
    else
      puts "#{image.name}"
    end
  end

end
