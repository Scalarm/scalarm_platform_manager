class CreateNodeManagers < ActiveRecord::Migration
  def change
    create_table :node_managers do |t|
      t.string :uri
      t.datetime :registered_at
    end
  end
end
