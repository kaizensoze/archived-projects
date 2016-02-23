class AddUtilitiesToListings < ActiveRecord::Migration
  def change
    add_column :listings, :utilities, :string
  end
end
