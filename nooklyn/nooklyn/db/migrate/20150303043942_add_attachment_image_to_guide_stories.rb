class AddAttachmentImageToGuideStories < ActiveRecord::Migration
  def self.up
    change_table :guide_stories do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :guide_stories, :image
  end
end
