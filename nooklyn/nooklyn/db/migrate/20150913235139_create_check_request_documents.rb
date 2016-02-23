class CreateCheckRequestDocuments < ActiveRecord::Migration
  def change
    create_table :check_request_documents do |t|

      t.timestamps null: false
    end
  end
end
