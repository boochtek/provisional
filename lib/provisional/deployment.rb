require "droplet_kit"


class Provisional::Deployment

  attr_reader :environment
  attr_reader :options

  def initialize(environment, options = {})
    @environment = environment
    @options = options
  end

  def deploy_cold
    verify_all_required_images_have_been_built(environment)
    puts "Deploying all images to '#{environment}'."
    deployment_config.each do |server_type, server_config|
      server_count = server_config["servers"]
      image = Provisional::Image.find(name: server_type)
      # For a cold deploy, we can assume (but should verify) that there are no existing servers in the environment.
      # existing_servers = Provisional::Server.list(environment).reject{|server| server.name =~ /-\d{14}/}
      # next_server_number = highest_server_number(existing_servers)
      new_server_numbers = (1 .. server_count)
      new_server_numbers.each do |server_number|
        server_name = "#{server_type}#{server_number}.#{environment}"
        puts "Create server #{server_name} with image '#{image.name}'"
        Provisional::Server.create(name: server_name, image: image)
      end
      # existing_servers.each do |server|
      #   server.delete
      # end
    end
  end

private

  def verify_all_required_images_have_been_built(environment)
    deployment_config.keys.each do |server_type|
      raise "No image built for '#{server_type}'" if Provisional::Image.find(name: server_type).nil?
    end
  end

  def deployment_config
    Provisional.config["deployments"][environment] or raise "No deployments config file section for '#{environment}'"
  end

  def highest_server_number(server_names)
    server_names.map{|name| name.split(".").first.gsub(/[^0-9]/, "").to_i}.sort.last
  end

end
