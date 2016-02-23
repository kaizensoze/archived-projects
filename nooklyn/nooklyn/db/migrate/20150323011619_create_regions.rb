class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :name
      t.integer :neighborhood_id
      t.boolean :featured, :default => false

      t.timestamps null: false
    end
  end
end
