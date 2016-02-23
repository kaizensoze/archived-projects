class AddAttachmentProfilePictureToAgents < ActiveRecord::Migration
  def self.up
    change_table :agents do |t|
      t.attachment :profile_picture
    end
  end

  def self.down
    drop_attached_file :agents, :profile_picture
  end
end
