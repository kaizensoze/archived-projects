class AddConvertibletoListings < ActiveRecord::Migration
  def change
    add_column :listings, :convertible, :boolean, :default => false
  end
end
