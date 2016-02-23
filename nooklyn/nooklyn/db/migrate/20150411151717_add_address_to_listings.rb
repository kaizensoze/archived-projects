class AddAddressToListings < ActiveRecord::Migration
  def change
    add_column :listings, :full_address, :string
    add_column :listings, :zip, :string
  end
end
