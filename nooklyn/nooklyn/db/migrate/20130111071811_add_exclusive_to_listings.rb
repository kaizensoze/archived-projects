class AddExclusiveToListings < ActiveRecord::Migration
  def change
    add_column :listings, :is_exclusive, :boolean, :default => false
  end
end
