class AddInformationToRoomPost < ActiveRecord::Migration
  def change
    add_column :room_posts, :ip_address, :string
    add_column :room_posts, :user_agent, :string
  end
end
