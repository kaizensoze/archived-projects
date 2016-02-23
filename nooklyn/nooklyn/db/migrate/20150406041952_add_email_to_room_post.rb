class AddEmailToRoomPost < ActiveRecord::Migration
  def change
    add_column :room_posts, :email, :string
  end
end
