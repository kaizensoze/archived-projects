class AddOwnerFeeToListings < ActiveRecord::Migration
  def change
    add_column :listings, :owner_pays, :float
  end
end
