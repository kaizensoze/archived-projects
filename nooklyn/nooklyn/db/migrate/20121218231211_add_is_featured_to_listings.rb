class AddIsFeaturedToListings < ActiveRecord::Migration
  def change
    add_column :listings, :is_featured, :boolean
  end
end
