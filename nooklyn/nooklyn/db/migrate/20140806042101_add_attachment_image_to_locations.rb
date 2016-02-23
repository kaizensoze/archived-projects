class AddAttachmentImageToLocations < ActiveRecord::Migration
  def self.up
    change_table :locations do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :locations, :image
  end
end
