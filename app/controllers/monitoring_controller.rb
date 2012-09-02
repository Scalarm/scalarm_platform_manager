require "mongo"

class MonitoringController < ApplicationController
  MONITORING_TABLE_PATTERN = /.*_.*_.*\..*___.*___.*/
  before_filter :authenticate
  before_filter :prepare_db_connection

  def index
    if @monitoring_db != nil
      collections = @monitoring_db.collection_names.select do |collection_name|
        collection_name =~ MonitoringController::MONITORING_TABLE_PATTERN
      end

      @measurements = {}
      collections.each do |collection|
        host_part, metric_part = collection.split(".")

        @measurements[host_part] = [] if not @measurements.has_key? host_part

        @measurements[host_part] << metric_part
      end
      # @measurements = @measurements.sort_by{|host_part, metrics| host_part}

    else
      flash[:error] = "Could not connect to the Monitoring DB"

      redirect_to :controller => "platform", :action => "index"
    end
  end

  def monitor
    parse_monitoring_options
    @metrics = {}

    params.each do |param_name, param_value|
      next if (param_name =~ MonitoringController::MONITORING_TABLE_PATTERN).nil?

      @metrics[param_name] = measurements_for param_name
      logger.debug("Metric measurements for #{param_name}: #{@metrics[param_name]}")
    end

    @grouped_metrics = @metrics.keys.group_by do |metric_name|
      splitted = metric_name.split(".")[1].split("___")
      "#{splitted[0]}___#{splitted[2]}"
    end

    logger.debug("Grouped metrics: #{map_to_string(@grouped_metrics)}")

    @chart_data = {}
    @grouped_metrics.each do |metric_name, metric_list|
      series = []
      metric_list.each do |metric_info|
        splitted = metric_info.split(".")
        series_name = "#{splitted[0]}"
        if splitted[1].split("___")[1] != "NULL"
          series_name += "___#{splitted[1].split("___")[1]}"
        end
        series_data = @metrics[metric_info].map{|t| "[#{t.join(",")}]" }.join(",")

        series << "{ name: '#{series_name}', data: [ #{series_data} ]  }"
      end

      @chart_data[metric_name] = series.join(",")
    end
  end


  private

  def string_to_time(string_date)
    DateTime.strptime(string_date, "%Y-%m-%d %H:%M:%S").to_time
  end

  def measurements_for(metric_name)
    metric_values = @monitoring_db[metric_name].find(date_find_conditions,
                      {:sort => ["date", :ascending],
                       :fields => {"_id" => 0, "date" => 1, "value" => 1}}
                    ).to_a.map{|doc|
                    [ string_to_time(doc["date"]).to_i, doc["value"].to_f ] }

    # logger.info(metric_values.map{|x| x[0]}.join(","))

    grouped_values, measurements_from_time_period = [], []

    last_measurement_date = metric_values[0][0]
    metric_values[1..-1].each do |metric_value|
      measurement_date = metric_value[0]

      if measurement_date - last_measurement_date < @time_resolution
        measurements_from_time_period << metric_value[1]
        next
      end

      measurements_from_time_period << metric_value[1]
      grouped_values << calculate_avg_from(last_measurement_date, measurements_from_time_period)
      grouped_values << calculate_avg_from(metric_value[0], measurements_from_time_period)
      last_measurement_date = metric_value[0]
      measurements_from_time_period = []
    end

    if not measurements_from_time_period.empty?
      grouped_values << calculate_avg_from(metric_values[-1][0], measurements_from_time_period)
    end

    grouped_values
  end

  def calculate_avg_from(timestamp, measurements_from_time_period)
    metric_value_sum = measurements_from_time_period.reduce(0, :+)
    metric_value_avg = metric_value_sum / measurements_from_time_period.size

    # logger.info("Sum = #{metric_value_sum} --- Size: #{measurements_from_time_period.size} --- Avg: #{metric_value_avg}")

    [timestamp*1000, metric_value_avg]
  end

  def date_find_conditions
    find_conditions = {}
    if not @monitoring_period_start.nil?
      find_conditions["date"] = { "$gt" => @monitoring_period_start }
    end

    if not @monitoring_period_end.nil?
      if find_conditions["date"]
        find_conditions["date"]["$lte"] = @monitoring_period_end
      else
        find_conditions["date"] = { "$lte" => @monitoring_period_end }
      end
    end

    find_conditions
  end

  def prepare_db_connection
    @config = YAML.load_file(File.join(Rails.root, "config", "platform_manager_config.yml"))
    logger.debug("Monitoring DB URL: #{@config["monitoring_db_url"]}")
    monitoring_db_ip, monitoring_db_port = @config["monitoring_db_url"].split(":")

    begin
      logger.debug("IP: #{monitoring_db_ip} --- Port: #{monitoring_db_port}")
      @monitoring_db = Mongo::Connection.new(monitoring_db_ip, monitoring_db_port.to_i).db(@config["monitoring_db_name"])
      logger.debug("Monitoring DB: #{@monitoring_db}")

      if @config.has_key? "monitoring_db_login"
        auth = @monitoring_db.authenticate(@config["monitoring_db_login"], @config["monitoring_db_password"])
        raise "Could not authenticated" if not auth
      end
    rescue Exception => e
      logger.error("Could not connect to the monitoring db")
      @monitoring_db = nil
    end
  end

  def parse_monitoring_options
    @time_resolution = params[:time_resolution].to_i

    #monitoring period params
    @monitoring_period_start = params[:monitoring_period_start]
    @monitoring_period_start = nil if @monitoring_period_start.blank?
    @monitoring_period_start = "#{@monitoring_period_start} #{params[:monitoring_period_start_time]}"

    @monitoring_period_end = params[:monitoring_period_end]
    @monitoring_period_end = nil if @monitoring_period_end.blank?
    @monitoring_period_end = "#{@monitoring_period_end} #{params[:monitoring_period_end_time]}"

    logger.info("Monitoring time period: #{@monitoring_period_start} - #{@monitoring_period_end}")

    @online_monitoring = params[:online_monitoring]
  end

end
