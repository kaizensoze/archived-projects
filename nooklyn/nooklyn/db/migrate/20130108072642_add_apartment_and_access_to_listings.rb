class AddApartmentAndAccessToListings < ActiveRecord::Migration
  def change
    add_column :listings, :apartment, :string
    add_column :listings, :access, :text
  end
end
