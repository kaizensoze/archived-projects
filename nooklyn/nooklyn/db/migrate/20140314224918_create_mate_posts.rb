class CreateMatePosts < ActiveRecord::Migration
  def change
    create_table :mate_posts do |t|
      t.text :description
      t.float :price
      t.boolean :cats
      t.boolean :dogs
      t.integer :neighborhood_id
      t.integer :agent_id

      t.timestamps
    end
  end
end
