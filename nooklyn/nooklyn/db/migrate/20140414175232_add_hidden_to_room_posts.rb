class AddHiddenToRoomPosts < ActiveRecord::Migration
  def change
    add_column :room_posts, :hidden, :boolean, :default => false
  end
end
