require "droplet_kit"


class Provisional::ImageOperations

  SSH_OPTIONS = "-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o CheckHostIP=no -o VisualHostKey=no"

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
    puts "Base image for '#{image_name}' is '#{base_image_for(image_name)}'"
    base_image = Provisional::Image.find(name: base_image_for(image_name))
    name = "#{image_name}-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"
    server = Provisional::Server.create(name: name, image: base_image)
    transfer_files_to_server(image_name, server)
    run_scripts_on_server(image_name, server)
    Provisional::Server.stop(server)
    build_image_from_server(name, server.id)
    Provisional::Server.delete(server)
  end

  def transfer_files_to_server(image_name, server)
    ip_address = server.public_ip
    wait_until_ssh_responds(ip_address)
    %x(ssh #{SSH_OPTIONS} root@#{ip_address} mkdir -p /var/tmp/provisional)
    %x(scp #{SSH_OPTIONS} -r #{Provisional::CONFIG_DIRECTORY}/#{image_name}/files/ root@#{ip_address}:/var/tmp/provisional/files/) if Dir.exists?("#{Provisional::CONFIG_DIRECTORY}/#{image_name}/files")
    %x(scp #{SSH_OPTIONS} -r #{Provisional::CONFIG_DIRECTORY}/#{image_name}/scripts/ root@#{ip_address}:/var/tmp/provisional/scripts/) if Dir.exists?("#{Provisional::CONFIG_DIRECTORY}/#{image_name}/scripts")
    %x(ssh #{SSH_OPTIONS} root@#{ip_address} chmod --silent 600 /var/tmp/provisional/files/*)
    %x(ssh #{SSH_OPTIONS} root@#{ip_address} chmod --silent 700 /var/tmp/provisional/scripts/*)
  end

  def run_scripts_on_server(image_name, server)
    ip_address = server.public_ip
    wait_until_ssh_responds(ip_address)
    %x(ssh #{SSH_OPTIONS} root@#{ip_address} run-parts --regex \\'.*\\' /var/tmp/provisional/scripts/)
  end

  def wait_until_ssh_responds(ip_address)
    until %x(ssh #{SSH_OPTIONS} root@#{ip_address} "ls -d1 /") == "/\n"
      puts "Waiting for SSH on #{ip_address} to respond"
      sleep 1
    end
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

  def custom_images
    @custom_images ||= all_images.select{|image| !image.public && image.name =~ /-\d{14}$/}
  end

  def all_images
    @all_images ||= Provisional.digital_ocean.images.all.select{|image| image.type == "snapshot"}
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

  def display(image)
    if image.public
      puts "#{image.slug}: #{image.distribution} #{image.name}"
    else
      puts "#{image.name}"
    end
  end

end
