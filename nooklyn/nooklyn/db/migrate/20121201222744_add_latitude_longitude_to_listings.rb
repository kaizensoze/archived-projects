class AddLatitudeLongitudeToListings < ActiveRecord::Migration
  def up
    add_column :listings, :latitude, :float
    add_column :listings, :longitude, :float
  end
  
  def down
    remove_column :listings, :latitude
    remove_column :listings, :longitude
  end
end
