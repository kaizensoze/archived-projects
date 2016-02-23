class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.integer :listing_id
      t.integer :occupant_id
      t.integer :landlord_id
      t.integer :final_price
      t.date :lease_starts
      t.date :lease_ends

      t.timestamps
    end
  end
end
