class AddPrivatetoListings < ActiveRecord::Migration
  def change
    add_column :listings, :private, :boolean, :default => false
  end
end
