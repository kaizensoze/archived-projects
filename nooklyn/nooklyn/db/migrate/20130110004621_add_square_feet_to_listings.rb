class AddSquareFeetToListings < ActiveRecord::Migration
  def change
    add_column :listings, :square_feet, :integer
  end
end
