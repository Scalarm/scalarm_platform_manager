#!/usr/bin/env ruby
require "yaml"

# utilities functions
module ScalarmPlatformManager

  def self.start_server(port)
    puts server_start_cmd(port)
    system(server_start_cmd(port))
  end

  def self.stop_server(port)
    self.server_procs_list(port).each do |process_line|
      pid = process_line.split(" ")[1]
      puts "kill -9 #{pid}"
      system("kill -9 #{pid}")
    end

    File.delete("tmp/pids/server.pid")
  end

  def self.server_start_cmd(port)
    "rails s -d -p #{port} -e development"
  end

  def self.server_procs_list(port)
    out = %x[ps aux | grep "rails.*#{port}"]
    out.split("\n").delete_if{|line| line.include? "grep"}
  end

end

# main
config = YAML.load_file(File.join(".", "config", "platform_manager_config.yml"))

if ARGV.size < 1 or ['start', 'stop', 'restart', 'status'].include?(ARGV[1])
	puts "usage scalarm_experiment_manager (start|stop|restart)"
  exit(1)
end

port = config["port"]

case ARGV[0]

when "start" then
  ScalarmPlatformManager.start_server(port)

when "stop" then
  ScalarmPlatformManager.stop_server(port)

when "restart" then
  ScalarmPlatformManager.start_server(port)
  ScalarmPlatformManager.stop_server(port)

when 'status' then
  server_status = ScalarmPlatformManager.server_procs_list(port).size

  if server_status == 0
    puts "Scalarm Platform Manager is not running"
  else
    puts "Scalarm Platform Manager is running in #{server_status} instances"
  end

end
