class RemoveNeighborhoodIdFromRegions < ActiveRecord::Migration
  def change
    remove_column :regions, :neighborhood_id, :integer
  end
end
