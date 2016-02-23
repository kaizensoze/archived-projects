class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :mate_posts, :agent_id
    add_index :mate_posts, :neighborhood_id
    add_index :mate_post_likes, [:agent_id, :mate_post_id]
    add_index :mate_post_likes, :agent_id
    add_index :mate_post_likes, :mate_post_id
    add_index :leads, :agent_id
    add_index :key_checkouts, :agent_id
    add_index :key_checkouts, :office_id
    add_index :guides, :neighborhood_id
    add_index :neighborhoods, :region_id
    add_index :mate_post_comments, :mate_post_id
    add_index :mate_post_comments, :agent_id
    add_index :locations, :neighborhood_id
    add_index :locations, :location_category_id
    add_index :hearts, [:agent_id, :listing_id]
    add_index :hearts, :agent_id
    add_index :hearts, :listing_id
    add_index :room_post_likes, [:agent_id, :room_post_id]
    add_index :room_post_likes, :agent_id
    add_index :room_post_likes, :room_post_id
    add_index :lead_updates, :lead_id
    add_index :lead_updates, :agent_id
    add_index :guide_stories, :guide_id
    add_index :guide_stories, :neighborhood_id
    add_index :listings, :listing_agent_id
    add_index :listings, :sales_agent_id
    add_index :listings, :neighborhood_id
    add_index :listings, :office_id
    add_index :room_posts, :agent_id
    add_index :room_posts, :neighborhood_id
    add_index :room_post_comments, :room_post_id
    add_index :room_post_comments, :agent_id
    add_index :rooms, :room_post_id
    add_index :rooms, :room_category_id
    add_index :photos, :listing_id
    add_index :open_houses, :listing_id
    add_index :open_houses, :agent_id
  end
end
