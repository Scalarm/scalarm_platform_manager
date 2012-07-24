class AddCompatibilityFlagsToNodeManager < ActiveRecord::Migration
  def change
    add_column :node_managers, :experiment_manager_compatible, :boolean, :default => false

    add_column :node_managers, :storage_manager_compatible, :boolean, :default => false

    add_column :node_managers, :simulation_manager_compatible, :boolean, :default => false
  end
end
