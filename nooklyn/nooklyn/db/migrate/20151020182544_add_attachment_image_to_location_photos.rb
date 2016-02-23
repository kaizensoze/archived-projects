class AddAttachmentImageToLocationPhotos < ActiveRecord::Migration
  def self.up
    change_table :location_photos do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :location_photos, :image
  end
end
