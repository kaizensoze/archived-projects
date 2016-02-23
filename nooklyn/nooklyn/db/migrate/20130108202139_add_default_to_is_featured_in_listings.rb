class AddDefaultToIsFeaturedInListings < ActiveRecord::Migration
  def up
    change_column :listings, :is_featured, :boolean, :default => false
end

def down
    change_column :listings, :is_featured, :boolean, :default => nil
end
end
