class AddRoomPostIdToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :room_post_id, :integer
  end
end
