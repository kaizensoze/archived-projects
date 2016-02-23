class CreateCheckRequests < ActiveRecord::Migration
  def change
    create_table :check_requests do |t|
      t.string :name
      t.string :apartment_address
      t.string :unit
      t.float :amount
      t.datetime :check_date
      t.boolean :type
      t.boolean :approved
      t.text :notes
      t.integer :agent_id

      t.timestamps null: false
    end
  end
end
