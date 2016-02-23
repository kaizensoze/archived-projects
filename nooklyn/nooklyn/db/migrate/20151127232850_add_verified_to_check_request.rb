class AddVerifiedToCheckRequest < ActiveRecord::Migration
  def change
    add_column :check_requests, :verified, :boolean, default: false
  end
end
