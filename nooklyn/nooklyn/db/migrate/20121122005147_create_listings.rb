class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.string :title
      t.text :description
      t.text :address
      t.date :available
      t.float :price
      t.float :bedrooms
      t.float :bathrooms
      t.boolean :pets
      t.string :fee
      t.string :neighborhood
      t.string :subway_line
      t.string :station
      t.text :amenities
      t.integer :landlord_id
      t.integer :marketing_agent_id
      t.integer :listing_agent_id
      t.string :term
      t.boolean :is_residential
      t.boolean :is_lease

      t.timestamps
    end
  end
end
