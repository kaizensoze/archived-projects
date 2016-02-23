class CreateDepositClients < ActiveRecord::Migration
  def change
    create_table :deposit_clients do |t|
      t.string :name
      t.boolean :guarantor
      t.integer :deposit_id

      t.timestamps null: false
    end
  end
end
