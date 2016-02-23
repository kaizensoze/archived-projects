class AddCatsOkAndDogsOkToListings < ActiveRecord::Migration
  def change
    add_column :listings, :cats_ok, :boolean
    add_column :listings, :dogs_ok, :boolean
  end
end
