class CreateMatePostLikes < ActiveRecord::Migration
  def change
    create_table :mate_post_likes do |t|
      t.integer :agent_id
      t.integer :room_post_id

      t.timestamps
    end
  end
end
