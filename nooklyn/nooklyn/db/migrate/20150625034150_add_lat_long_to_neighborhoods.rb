class AddLatLongToNeighborhoods < ActiveRecord::Migration
  def change
    add_column :neighborhoods, :latitude, :float, :default => 0
    add_column :neighborhoods, :longitude, :float, :default => 0
  end
end
