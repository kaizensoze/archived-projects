class AddOfficeIdToKeyCheckouts < ActiveRecord::Migration
  def change
    add_column :key_checkouts, :office_id, :integer
  end
end
