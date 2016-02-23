class AddLatLngToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :latitude, :float
    add_column :regions, :longitude, :float
  end
end
