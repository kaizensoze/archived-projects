class AddAttachmentImageToRegions < ActiveRecord::Migration
  def self.up
    change_table :regions do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :regions, :image
  end
end
