class AddColumnsToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :owner_pays, :float
    add_column :deposits, :total_broker_fee, :float
    add_column :deposits, :application_fees, :float
  end
end
