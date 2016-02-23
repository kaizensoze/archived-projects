class AddRegionIdToNeighborhoods < ActiveRecord::Migration
  def change
    add_column :neighborhoods, :region_id, :integer
  end
end
