class AddAttachmentCoverImageToGuides < ActiveRecord::Migration
  def self.up
    change_table :guides do |t|
      t.attachment :cover_image
    end
  end

  def self.down
    remove_attachment :guides, :cover_image
  end
end
