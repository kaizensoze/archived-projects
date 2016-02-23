class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :listing_id
      t.integer :agent_id
      t.string :apartment
      t.integer :broker_fee
      t.integer :owner_pays
      t.string :type

      t.timestamps
    end
  end
end
