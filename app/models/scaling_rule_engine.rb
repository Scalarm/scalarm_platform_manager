class ScalingRuleEngine

  def start_rule_guards
    ScalingRule.all.each do |scaling_rule|
      delay.spawn_scaling_rule_guard_for(scaling_rule)
    end
  end

  def spawn_scaling_rule_guard_for(rule)
    guard = ScalingRuleGuard.new(rule)
    guard.watch
  end

  def self.execute_scaling_action(action_name)
    Rails.logger.debug("Execute Scaling action #{action_name}")

    action, manager_type, server_type = action_name.split("_")
    manager_type = "storage_db_instance" if manager_type == "storage"

    if action == "start"
      node_manager = NodeManager.find_one_without((server_type == "empty") ? nil : manager_type)
      if node_manager.nil?
        Rails.logger.debug("Couldn't find node manager to start a new server of type #{manager_type}")
      else
        Rails.logger.debug("Starting a new instance of #{manager_type} on #{node_manager.uri}")
        node_manager.start(manager_type, manager_type == "experiment" ? 8 : 1, CONFIG)
      end

      not node_manager.nil?

    elsif action == "stop"
      node_manager = NodeManager.find_one_with(manager_type)
      if node_manager.nil?
        Rails.logger.debug("Couldn't find appropriate node manager to stop #{manager_type}")
        false
      else
        Rails.logger.debug("Stopping an instance of #{manager_type} on #{node_manager.uri}")
        node_manager.stop(manager_type, manager_type == "experiment" ? 8 : 1, CONFIG)
      end

      not node_manager.nil?
    end
  end

  SCALING_ACTIONS = {
      "Start a new Experiment manager instance on an empty server" => "start_experiment_empty",
      "Start a new Experiment manager instance on an occupied server" => "start_experiment_occupied",
      "Stop an instance of Experiment manager" => "stop_experiment",
      "Start a new Storage manager instance on an empty server" => "start_storage_empty",
      "Start a new Storage manager instance on an occupied server" => "start_storage_occupied",
      "Stop an instance of Storage manager" => "stop_storage"
  }

  CONFIG = YAML.load_file(File.join(Rails.root, "config", "platform_manager_config.yml"))
end