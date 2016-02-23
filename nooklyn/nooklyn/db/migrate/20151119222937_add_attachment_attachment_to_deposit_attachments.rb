class AddAttachmentAttachmentToDepositAttachments < ActiveRecord::Migration
  def self.up
    change_table :deposit_attachments do |t|
      t.attachment :attachment
    end
  end

  def self.down
    remove_attachment :deposit_attachments, :attachment
  end
end
