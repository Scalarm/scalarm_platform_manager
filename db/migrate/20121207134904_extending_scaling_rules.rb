class ExtendingScalingRules < ActiveRecord::Migration
  def change
    add_column :scaling_rules, :time_window_length, :integer
    add_column :scaling_rules, :time_window_length_unit, :string
  end
end
