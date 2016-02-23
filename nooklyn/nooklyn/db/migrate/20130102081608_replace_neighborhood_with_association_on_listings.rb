class ReplaceNeighborhoodWithAssociationOnListings < ActiveRecord::Migration
  def up
    remove_column :listings, :neighborhood
    add_column :listings, :neighborhood_id, :integer
  end

  def down
    remove_column :listings, :neighborhood_id
    add_column :listings, :neighborhood, :string
  end
end
