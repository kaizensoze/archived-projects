class AddOfficeIdToListings < ActiveRecord::Migration
  def change
    add_column :listings, :office_id, :integer
  end
end
