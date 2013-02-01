require "mongo"

class MonitoringService
  MONITORING_TABLE_PATTERN = /.*_.*_.*\..*___.*___.*/
  attr_accessor :monitoring_db

  def initialize
    prepare_db_connection
  end

  def monitoring_metrics
    return {} if @monitoring_db.nil?

    measurements = {}

    collections = @monitoring_db.collection_names.select do |collection_name|
      collection_name =~ MonitoringController::MONITORING_TABLE_PATTERN
    end


    collections.each do |collection|
      host_part, metric_part = collection.split(".")

      measurements[host_part] = [] if not measurements.has_key? host_part

      measurements[host_part] << metric_part
    end

    measurements
  end

  def monitoring_data_for(scaling_rule)
    self.send("#{scaling_rule.measurement_type}_monitoring_data", scaling_rule)
  end

  def simple_monitoring_data(scaling_rule)
    @monitoring_db[scaling_rule.metric_name].find({}, {:sort => [["date", :desc]], :limit => 1}).to_a
  end

  def time_window_monitoring_data(scaling_rule)
    query = { "date" => { "$gt" => (Time.now - scaling_rule.time_window_length_in_secs).strftime("%Y-%m-%d %H:%M:%S") }}
    options = { :sort => [["date", :desc]], :fields => { "_id" => 0 } }

    @monitoring_db[scaling_rule.metric_name].find(query, options).to_a
  end

  private

  def prepare_db_connection
    @config = YAML.load_file(File.join(Rails.root, "config", "platform_manager_config.yml"))
    Rails.logger.debug("Monitoring DB URL: #{@config["monitoring_db_url"]}")
    monitoring_db_ip, monitoring_db_port = @config["monitoring_db_url"].split(":")

    begin
      Rails.logger.debug("IP: #{monitoring_db_ip} --- Port: #{monitoring_db_port}")
      @monitoring_db = Mongo::Connection.new(monitoring_db_ip, monitoring_db_port.to_i).db(@config["monitoring_db_name"])
      Rails.logger.debug("Monitoring DB: #{@monitoring_db}")

      if @config.has_key? "monitoring_db_login"
        auth = @monitoring_db.authenticate(@config["monitoring_db_login"], @config["monitoring_db_password"])
        raise "Could not authenticated" if not auth
      end
    rescue Exception => e
      Rails.logger.error("Could not connect to the monitoring db")
      @monitoring_db = nil
    end
  end
end