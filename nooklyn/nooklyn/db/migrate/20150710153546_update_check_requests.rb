class UpdateCheckRequests < ActiveRecord::Migration
  def change
    rename_column :check_requests, :type, :check_type
    change_column :check_requests, :approved, :boolean, :default => false
  end
end
