class AddSlugIndexToNeighborhoods < ActiveRecord::Migration
  def change
    add_index :neighborhoods, :slug
  end
end
