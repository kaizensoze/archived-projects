class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
      t.string :address
      t.string :unit
      t.integer :listing_agent_id
      t.integer :sales_agent_id
      t.integer :other_sales_agent_id
      t.float :apartment_price
      t.float :offer_price
      t.datetime :when
      t.string :full_address

      t.timestamps null: false
    end
  end
end
