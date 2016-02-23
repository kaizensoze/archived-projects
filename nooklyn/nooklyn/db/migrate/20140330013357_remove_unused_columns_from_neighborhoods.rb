class RemoveUnusedColumnsFromNeighborhoods < ActiveRecord::Migration
  def change
    remove_column :neighborhoods, :tag, :string
  end
end
