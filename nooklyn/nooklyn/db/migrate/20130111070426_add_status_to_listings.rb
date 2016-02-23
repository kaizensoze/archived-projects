class AddStatusToListings < ActiveRecord::Migration
  def change
    add_column :listings, :status, :string, :default => "Available"
  end
end
