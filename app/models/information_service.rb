class InformationService

  def initialize(config)
    @config = config
  end

  def list_of_node_managers
    sis_server, sis_port = @config["information_service_url"].split(":")

    http = Net::HTTP.new(sis_server, sis_port.to_i)
    req = Net::HTTP::Get.new("/node_managers")

    req.basic_auth @config["information_service_login"], @config["information_service_password"]
    begin
      response = http.request(req)
      return response.body.split("|||")
    rescue Exception => e
      logger.error("Could not connect to the Information Service")
      logger.error(e.message)
    end

    return []
  end

  def list_of_db_configs
    sis_server, sis_port = @config["information_service_url"].split(":")

    http = Net::HTTP.new(sis_server, sis_port.to_i)
    req = Net::HTTP::Get.new("/db_config_services")

    req.basic_auth @config["information_service_login"], @config["information_service_password"]
    begin
      response = http.request(req)
      return response.body
    rescue Exception => e
      logger.error("Could not connect to the Information Service")
      logger.error(e.message)
    end

    return ""
  end

  def list_of_db_instances
    sis_server, sis_port = @config["information_service_url"].split(":")

    http = Net::HTTP.new(sis_server, sis_port.to_i)
    req = Net::HTTP::Get.new("/db_instances")

    req.basic_auth @config["information_service_login"], @config["information_service_password"]
    begin
      response = http.request(req)
      return response.body
    rescue Exception => e
      logger.error("Could not connect to the Information Service")
      logger.error(e.message)
    end

    return ""

  end
end