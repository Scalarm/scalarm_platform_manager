class CreateScalingRules < ActiveRecord::Migration
  def change
    create_table :scaling_rules do |t|
      t.string :metric_name
      t.string :measurement__type
      t.string :condition
      t.string :threshold
      t.string :action

      t.timestamps
    end
  end
end
