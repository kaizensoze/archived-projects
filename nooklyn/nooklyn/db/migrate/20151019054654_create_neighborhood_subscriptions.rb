class CreateNeighborhoodSubscriptions < ActiveRecord::Migration
  def change
    create_table :neighborhood_subscriptions do |t|
      t.integer :agent_id
      t.integer :neighborhood

      t.timestamps null: false
    end
  end
end
