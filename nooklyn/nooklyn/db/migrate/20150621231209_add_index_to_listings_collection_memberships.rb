class AddIndexToListingsCollectionMemberships < ActiveRecord::Migration
  def change
    add_index :listings_collection_memberships, [:listing_id, :listings_collection_id], unique: true, name: "index_listings_collection_memberships"
  end
end
