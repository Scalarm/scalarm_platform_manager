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

    elsif manager_type == "storage"

      if not response.nil? and (response.empty? or response.include?("not running"))
        return "not running"
      else
        return "running"
      end

    end
  end

  private

  def send_request_to_remote_node_manager(path, config)
    snm_server, snm_port = self.uri.split(":")

    http = Net::HTTP.new(snm_server, snm_port.to_i)
    http.read_timeout = 3600
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
