class AddAddressToRoomPost < ActiveRecord::Migration
  def change
    add_column :room_posts, :full_address, :string
  end
end
