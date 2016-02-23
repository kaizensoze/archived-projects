class AddAttachmentAttachmentToCheckRequestDocuments < ActiveRecord::Migration
  def self.up
    change_table :check_request_documents do |t|
      t.attachment :attachment
    end
  end

  def self.down
    remove_attachment :check_request_documents, :attachment
  end
end
