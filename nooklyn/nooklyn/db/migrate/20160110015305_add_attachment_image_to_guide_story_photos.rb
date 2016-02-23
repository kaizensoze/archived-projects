class AddAttachmentImageToGuideStoryPhotos < ActiveRecord::Migration
  def self.up
    change_table :guide_story_photos do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :guide_story_photos, :image
  end
end
