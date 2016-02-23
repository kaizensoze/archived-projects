class RemoveColumnsFromDeposits < ActiveRecord::Migration
  def change
    remove_column :deposits, :application_fees
  end
end
