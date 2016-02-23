class AddPrimaryphotoToListings < ActiveRecord::Migration
  def change
    add_column :listings, :primaryphoto, :string
  end
end
