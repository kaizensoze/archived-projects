class AddAttachmentImageToLocationCategories < ActiveRecord::Migration
  def self.up
    change_table :location_categories do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :location_categories, :image
  end
end
