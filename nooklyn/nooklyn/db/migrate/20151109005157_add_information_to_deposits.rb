class AddInformationToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :length_of_lease, :string
    add_column :deposits, :landlord_llc, :string
    add_column :deposits, :deposit_status_id, :integer
  end
end
