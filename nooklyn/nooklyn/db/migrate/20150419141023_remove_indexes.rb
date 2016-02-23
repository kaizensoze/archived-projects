class RemoveIndexes < ActiveRecord::Migration
  def change
    remove_index :mate_posts, :agent_id
    remove_index :mate_posts, :neighborhood_id
    remove_index :mate_post_likes, [:agent_id, :mate_post_id]
    remove_index :mate_post_likes, :agent_id
    remove_index :mate_post_likes, :mate_post_id
  end
end
