class AddRejectedToCheckRequest < ActiveRecord::Migration
  def change
    add_column :check_requests, :rejected, :boolean, :default => false
  end
end
