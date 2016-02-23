class CreateLeads < ActiveRecord::Migration
  def change
    create_table :leads do |t|
      t.string :full_name
      t.string :phone
      t.string :email
      t.date :move_in
      t.boolean :pets
      t.float :min_price
      t.float :max_price
      t.text :comments
      t.datetime :contacted
      t.integer :agent_id
      t.boolean :is_landlord

      t.timestamps
    end
  end
end
