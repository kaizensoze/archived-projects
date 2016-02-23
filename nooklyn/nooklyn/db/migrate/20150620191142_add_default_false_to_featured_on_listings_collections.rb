class AddDefaultFalseToFeaturedOnListingsCollections < ActiveRecord::Migration
  def change
    change_column :listings_collections, :featured, :boolean, :default => false
  end
end
