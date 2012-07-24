class NodeManager < ActiveRecord::Base

  def install(manager_type, config)
    response = send_request_to_remote_node_manager("/install_manager/#{manager_type}", config)
    puts response
  end

  def start(manager_type, number, config)
    response = send_request_to_remote_node_manager("/start_manager/#{manager_type}/#{number}", config)
    puts response
  end

  def stop(manager_type, number, config)
    response = send_request_to_remote_node_manager("/stop_manager/#{manager_type}/#{number}", config)
    puts response
  end

  def uri_to_request
    self.uri.gsub(".", "_").gsub(":", "-")
  end

  def manager_status(manager_type, number, config)
    response = send_request_to_remote_node_manager("/manager_status/#{manager_type}/#{number}", config)
    if response.include?("is running in")
      response.split("is running in")[1]
    else 
      "not running"
    end
  end

  private

  def send_request_to_remote_node_manager(path, config)
    snm_server, snm_port = self.uri.split(":")

    http = Net::HTTP.new(snm_server, snm_port.to_i)
    http.read_timeout = 3600
    req = Net::HTTP::Get.new(path)

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
