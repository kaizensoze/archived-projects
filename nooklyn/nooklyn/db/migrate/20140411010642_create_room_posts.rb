class CreateRoomPosts < ActiveRecord::Migration
  def change
    create_table :room_posts do |t|
      t.text :description
      t.float :price
      t.boolean :cats
      t.boolean :dogs
      t.integer :neighborhood_id
      t.integer :agent_id
      t.datetime :when

      t.timestamps
    end
  end
end
