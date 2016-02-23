class CreateListingsCollectionMemberships < ActiveRecord::Migration
  def change
    create_table :listings_collection_memberships do |t|
      t.timestamps
      t.references :listing
      t.references :listings_collection
    end
  end
end
