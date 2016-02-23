class CreateLandlords < ActiveRecord::Migration
  def change
    create_table :landlords do |t|
      t.string :legal_name
      t.string :building_address
      t.string :llc

      t.timestamps
    end
  end
end
