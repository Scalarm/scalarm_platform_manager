module ScalingRulesHelper

  def measurement_type_options
    [["Simple", "simple"], ["Time window", "time_window"]]
  end

  def condition_options
    [">", "<", "=", "<=", ">="]
  end

  def action_options
    ScalingRuleEngine::SCALING_ACTIONS.reduce([]){|actions, action_pair| actions << action_pair}
  end

  def time_window_length_units_options
    [["Seconds", "s"], ["Minutes", "m"], ["Hours", "h"]]
  end
end
