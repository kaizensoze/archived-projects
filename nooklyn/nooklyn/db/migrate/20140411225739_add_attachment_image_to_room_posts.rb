class AddAttachmentImageToRoomPosts < ActiveRecord::Migration
  def self.up
    change_table :room_posts do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :room_posts, :image
  end
end
