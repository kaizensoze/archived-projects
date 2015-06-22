class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :device_id, :string
    add_column :users, :auth_token, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :type, :string
    add_column :users, :section_number, :string
    add_column :users, :class_year, :string

    add_index :users, :device_id
    add_index :users, :auth_token
  end
end
