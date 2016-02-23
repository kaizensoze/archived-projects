class AddFeaturedToNeighborhoods < ActiveRecord::Migration
  def change
    add_column :neighborhoods, :featured, :boolean
  end
end
