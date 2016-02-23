class RemoveUnusedColumnsFromListing < ActiveRecord::Migration
  def change
    remove_column :listings, :landlord_id, :integer
    remove_column :listings, :photo_tag, :string
    remove_column :listings, :building_tag, :string
    remove_column :listings, :cats_ok, :boolean
    remove_column :listings, :dogs_ok, :boolean
  end
end
