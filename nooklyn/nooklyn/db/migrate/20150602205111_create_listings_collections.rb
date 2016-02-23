class CreateListingsCollections < ActiveRecord::Migration
  def change
    create_table :listings_collections do |t|
      t.timestamps
      t.references :agent
      t.string :name, null: false
      t.boolean :private, default: false
      t.text :description
    end
  end
end
