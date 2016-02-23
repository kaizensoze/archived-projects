class AddAttachmentImageToMateposts < ActiveRecord::Migration
  def self.up
    change_table :mate_posts do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :mate_posts, :image
  end
end
