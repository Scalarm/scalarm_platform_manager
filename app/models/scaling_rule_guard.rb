class ScalingRuleGuard

  def initialize(scaling_rule)
    @scaling_rule = scaling_rule
    @monitoring = MonitoringService.new
  end

  def watch
    Rails.logger.debug("Guard of ScalingRule #{@scaling_rule.id}: starting guarding")

    while true
      break if ScalingRule.where("id" => @scaling_rule.id).count == 0

      if rule_condition_is_met
        Rails.logger.debug("Guard of ScalingRule #{@scaling_rule.id}: rule condition is met")
        ScalingRuleEngine.execute_scaling_action(@scaling_rule.action)
        cool_down
      end
      sleep(20)
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

  def cool_down
    Rails.logger.debug("Cooling down after performing scaling action")
    sleep(300)
  end

end