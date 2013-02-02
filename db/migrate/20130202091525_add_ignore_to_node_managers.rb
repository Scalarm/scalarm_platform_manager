class AddIgnoreToNodeManagers < ActiveRecord::Migration
  def change
    add_column :node_managers, :ignore, :boolean

  end
end
