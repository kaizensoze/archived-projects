class AddFeaturedToListingsCollections < ActiveRecord::Migration
  def change
    add_column :listings_collections, :featured, :boolean
  end
end
