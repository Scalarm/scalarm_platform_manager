class FixMeasurementTypeColumnName < ActiveRecord::Migration

  def change
    rename_column :scaling_rules, :measurement__type, :measurement_type
  end
end
