class AddIndexesToListings < ActiveRecord::Migration
  def change
    add_index :listings, :status
    add_index :listings, :primaryphoto
  end
end
