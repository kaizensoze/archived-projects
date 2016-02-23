class AddDefaultToFeaturedToNeighborhoods < ActiveRecord::Migration
  def change
    change_column :neighborhoods, :featured, :boolean, :default => false
  end
end
