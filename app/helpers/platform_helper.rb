module PlatformHelper

  def manager_installation_options
    [
        ["Experiment Manager", "experiment"],
        ["Storage Manager", "storage"],
        ["Simulation Manager", "simulation"]
    ]
  end

  def global_action_options
    [
        ["start", "start"],
        ["stop", "stop"]
    ]
  end

  def manager_type_options
    [
        ["Experiment Manager", "experiment"],
        ["Storage Manager - database instance", "storage_db_instance"],
        ["Simulation Manager", "simulation"],
    ]
  end

  def local_manager_type_options
    [
        ["Experiment Manager", "experiment"],
        ["Storage Manager - config service", "storage_db_config"],
        ["Storage Manager - database instance", "storage_db_instance"],
        ["Storage Manager - router", "storage_db_router"],
        ["Simulation Manager", "simulation"],
    ]
  end
end
