class ScalingRuleGuard
  CHECKING_INTERVAL = 20

  def initialize(scaling_rule)
    @scaling_rule = scaling_rule
    @monitoring = MonitoringService.new
  end

  def watch
    Rails.logger.debug("Guard of ScalingRule #{@scaling_rule.id}: starting guarding")

    while true
      # wait until there is no cool down periods
      last_cool_down_period = CoolDownPeriod.order("start_date DESC").first
      if (not last_cool_down_period.nil?) and (Time.now < last_cool_down_period.end_date)
        when_to_awake = last_cool_down_period.end_date - Time.now
        
        Rails.logger.debug("ScalingRule[#{@scaling_rule.id}] guard: sleeping for #{when_to_awake} [s] due to cool down period")
        sleep(when_to_awake.to_i)
      end

      break if ScalingRule.where("id" => @scaling_rule.id).count == 0

      if rule_condition_is_met
        Rails.logger.debug("Guard of ScalingRule #{@scaling_rule.id}: rule condition is met")
        executed_success = ScalingRuleEngine.execute_scaling_action(@scaling_rule.action)
        cool_down(@scaling_rule) if executed_success
      end

      sleep(CHECKING_INTERVAL)
    end

    Rails.logger.debug("Guard of ScalingRule #{@scaling_rule.id}: quiting guarding")
  end

  def rule_condition_is_met
    monitoring_data = @monitoring.monitoring_data_for(@scaling_rule)
    Rails.logger.debug("Monitoring data #{monitoring_data.inspect}")

    value = if @scaling_rule.measurement_type == "simple"
      monitoring_data.first["value"].to_f
            elsif @scaling_rule.measurement_type == "time_window"
      (monitoring_data.reduce(0.0){ |sum, x| sum += x["value"].to_f}) / monitoring_data.size
            end

    Rails.logger.debug("Condition is met #{value.send(@scaling_rule.condition, @scaling_rule.threshold.to_f)}");
    value.send(@scaling_rule.condition, @scaling_rule.threshold.to_f)
  end

  def cool_down(executed_scaling_rule)
    Rails.logger.debug("Cooling down after performing scaling action")
    CoolDownPeriod.new({:start_date => Time.now,
                        :end_date => Time.now + CoolDownPeriod::PERIOD_LENGTH.seconds,
                        :reason => executed_scaling_rule.as_string }).save
  end

end