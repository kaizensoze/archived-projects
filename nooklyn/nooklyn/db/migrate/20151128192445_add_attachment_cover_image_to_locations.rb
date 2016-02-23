class AddAttachmentCoverImageToLocations < ActiveRecord::Migration
  def self.up
    change_table :locations do |t|
      t.attachment :cover_image
    end
  end

  def self.down
    remove_attachment :locations, :cover_image
  end
end
