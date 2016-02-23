class CreateLocationLikes < ActiveRecord::Migration
  def change
    create_table :location_likes do |t|
      t.integer :agent_id
      t.integer :location_id

      t.timestamps null: false
    end
  end
end
