class AddLocationToRoomPosts < ActiveRecord::Migration
  def change
    add_column :room_posts, :latitude, :float
    add_column :room_posts, :longitude, :float
    add_column :room_posts, :cross_streets, :string
  end
end
