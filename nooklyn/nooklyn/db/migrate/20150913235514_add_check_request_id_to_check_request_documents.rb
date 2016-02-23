class AddCheckRequestIdToCheckRequestDocuments < ActiveRecord::Migration
  def change
    add_column :check_request_documents, :check_request_id, :integer
  end
end
