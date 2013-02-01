require "spawn"

class ScalingRulesController < ApplicationController

  def index
    @monitoring_service = MonitoringService.new
    @scaling_rules = ScalingRule.all
    @scaling_rule = ScalingRule.new
  end

  def create_new
    params["scaling_rule"]["metric_name"] = "#{params["host"]}.#{params["metric"]}"
    rule = ScalingRule.new(params["scaling_rule"])
    rule.save

    engine = ScalingRuleEngine.new
    engine.delay.spawn_scaling_rule_guard_for rule

    redirect_to :action => :index
  end

  def delete_rule
    ScalingRule.destroy(params["scaling_rule_id"])
    redirect_to :action => :index
  end

end
