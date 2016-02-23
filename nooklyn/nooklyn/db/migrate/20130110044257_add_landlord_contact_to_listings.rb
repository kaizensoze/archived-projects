class AddLandlordContactToListings < ActiveRecord::Migration
  def change
    add_column :listings, :landlord_contact, :string
  end
end
