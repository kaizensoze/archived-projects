class AddAttachmentPictureToRooms < ActiveRecord::Migration
  def self.up
    change_table :rooms do |t|
      t.attachment :picture
    end
  end

  def self.down
    drop_attached_file :rooms, :picture
  end
end
