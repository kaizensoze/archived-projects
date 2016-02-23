class AddAttachmentImageToNeighborhoods < ActiveRecord::Migration
  def self.up
    change_table :neighborhoods do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :neighborhoods, :image
  end
end
