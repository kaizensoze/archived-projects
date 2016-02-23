class AddCreditChecksToDeposit < ActiveRecord::Migration
  def change
    add_column :deposits, :credit_check, :string
  end
end
