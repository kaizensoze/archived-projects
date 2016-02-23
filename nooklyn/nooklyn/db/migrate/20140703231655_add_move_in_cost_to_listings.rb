class AddMoveInCostToListings < ActiveRecord::Migration
  def change
    add_column :listings, :move_in_cost, :boolean
  end
end
