class AddFeaturedToRoomPosts < ActiveRecord::Migration
  def change
    add_column :room_posts, :featured, :boolean, :default => false
  end
end
