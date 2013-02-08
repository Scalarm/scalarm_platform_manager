class CreateCoolDownPeriods < ActiveRecord::Migration
  def change
    create_table :cool_down_periods do |t|
      t.timestamp :start_date
      t.timestamp :end_date
      t.string :reason
    end
  end
end
