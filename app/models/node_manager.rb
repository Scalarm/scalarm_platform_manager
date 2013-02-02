require "net/http"

class NodeManager < ActiveRecord::Base

  def install(manager_type, config)
    response = send_request_to_remote_node_manager("/install_manager/#{manager_type}", config)
    Rails.logger.debug(response)
  end

  def start(manager_type, number, config)
    response = send_request_to_remote_node_manager("/start_manager/#{manager_type}/#{number}", config)
    Rails.logger.debug(response)
  end

  def stop(manager_type, number, config)
    response = send_request_to_remote_node_manager("/stop_manager/#{manager_type}/#{number}", config)
    Rails.logger.debug(response)
  end

  def uri_to_request
    self.uri.gsub(".", "_").gsub(":", "-")
  end

  def manager_status(manager_type, number, config)
    response = send_request_to_remote_node_manager("/manager_status/#{manager_type}/#{number}", config)

    if manager_type == "experiment"

      if not response.nil? and response.include?("is running in")
        return response.split("is running in")[1]
      else
        return "not running"
      end

    elsif manager_type.include? "storage"

      if not response.nil? and (response.empty? or response.include?("not running"))
        return "not running"
      else
        return "running"
      end

    end
  end

  def self.find_one_without(manager_type = nil)
    manager_types = manager_type.nil? ? [ "experiment", "storage_db_config", "storage_db_instance" ] : manager_type
    config = YAML.load_file(File.join(Rails.root, "config", "platform_manager_config.yml"))

    NodeManager.where(:ignore => false).each do |node_manager|
      any_manager_running = false
      manager_types.each do |type|
        status = node_manager.manager_status(type, 1, config)
        Rails.logger.debug("Status: #{status}")
        if status != "not running"
          any_manager_running = true
          break
        end
      end

      return node_manager if not any_manager_running
    end

    nil
  end

  def self.find_one_with(manager_type)
    config = YAML.load_file(File.join(Rails.root, "config", "platform_manager_config.yml"))

    NodeManager.where(:ignore => false).each do |node_manager|
      return node_manager if node_manager.manager_status(manager_type, 1, config) != "not running"
    end

    nil
  end

  private

  def send_request_to_remote_node_manager(path, config)
    snm_server, snm_port = self.uri.split(":")

    http = Net::HTTP.new(snm_server, snm_port.to_i)
    http.read_timeout = 20
    req = Net::HTTP::Get.new(path)
    Rails.logger.debug("Sending: http://#{snm_server}:#{snm_port}#{path}")

    req.basic_auth config["node_manager_login"], config["node_manager_password"]

    begin
      response = http.request(req)
      return response.body
    rescue Exception => e
      logger.error("Error occured during remote communication")
      logger.error(e.message)
    end

    nil
  end
end
