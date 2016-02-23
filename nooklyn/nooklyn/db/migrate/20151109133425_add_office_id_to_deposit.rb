class AddOfficeIdToDeposit < ActiveRecord::Migration
  def change
    add_column :deposits, :office_id, :integer
  end
end
