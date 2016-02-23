class AddSlugToListingsCollections < ActiveRecord::Migration
  def change
    add_column :listings_collections, :slug, :string
    add_index :listings_collections, :slug, unique: true
  end
end
