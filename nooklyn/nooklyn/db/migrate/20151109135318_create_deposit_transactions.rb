class CreateDepositTransactions < ActiveRecord::Migration
  def change
    create_table :deposit_transactions do |t|
      t.float :amount
      t.string :deposit_transaction_type
      t.string :client_name
      t.integer :office_id
      t.integer :deposit_id
      t.text :notes

      t.timestamps null: false
    end
  end
end
