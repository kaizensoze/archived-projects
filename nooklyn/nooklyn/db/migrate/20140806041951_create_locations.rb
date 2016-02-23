class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.text :description
      t.float :latitude
      t.float :longitude
      t.string :address_line_one
      t.string :address_line_two
      t.string :city
      t.string :state
      t.integer :zip
      t.integer :neighborhood_id
      t.integer :website
      t.string :facebook_url
      t.string :delivery_website
      t.string :yelp_url
      t.string :phone_number
      t.integer :location_category_id

      t.timestamps
    end
  end
end
