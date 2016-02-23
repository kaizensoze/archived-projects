class ChangeDefaultsOnRoomPost < ActiveRecord::Migration
  def change
    change_column :room_posts, :dogs, :boolean, :default => false
    change_column :room_posts, :cats, :boolean, :default => false
  end
end
