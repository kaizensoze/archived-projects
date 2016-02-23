class AddCrossStreetsToListings < ActiveRecord::Migration
  def change
    add_column :listings, :cross_streets, :string
  end
end
