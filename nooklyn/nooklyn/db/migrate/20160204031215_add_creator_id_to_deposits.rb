class AddCreatorIdToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :creator_id, :integer
    add_column :deposit_transactions, :creator_id, :integer
    add_column :deposit_clients, :creator_id, :integer
  end
end
