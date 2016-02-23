class RemoveAllIndexes < ActiveRecord::Migration
  def change
    remove_index :leads, :agent_id
    remove_index :key_checkouts, :agent_id
    remove_index :key_checkouts, :office_id
    remove_index :guides, :neighborhood_id
    remove_index :neighborhoods, :region_id
    remove_index :mate_post_comments, :mate_post_id
    remove_index :mate_post_comments, :agent_id
    remove_index :locations, :neighborhood_id
    remove_index :locations, :location_category_id
    remove_index :hearts, [:agent_id, :listing_id]
    remove_index :hearts, :agent_id
    remove_index :hearts, :listing_id
    remove_index :room_post_likes, [:agent_id, :room_post_id]
    remove_index :room_post_likes, :agent_id
    remove_index :room_post_likes, :room_post_id
    remove_index :lead_updates, :lead_id
    remove_index :lead_updates, :agent_id
    remove_index :guide_stories, :guide_id
    remove_index :guide_stories, :neighborhood_id
    remove_index :listings, :listing_agent_id
    remove_index :listings, :sales_agent_id
    remove_index :listings, :neighborhood_id
    remove_index :listings, :office_id
    remove_index :room_posts, :agent_id
    remove_index :room_posts, :neighborhood_id
    remove_index :room_post_comments, :room_post_id
    remove_index :room_post_comments, :agent_id
    remove_index :rooms, :room_post_id
    remove_index :rooms, :room_category_id
    remove_index :photos, :listing_id
    remove_index :open_houses, :listing_id
    remove_index :open_houses, :agent_id
  end
end
