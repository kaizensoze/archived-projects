class AddLordlordLlcToListings < ActiveRecord::Migration
  def change
    add_column :listings, :landlord_llc, :string
  end
end
