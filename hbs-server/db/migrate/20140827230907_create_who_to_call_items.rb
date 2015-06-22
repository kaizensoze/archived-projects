class CreateWhoToCallItems < ActiveRecord::Migration
  def change
    create_table :who_to_call_items do |t|
      t.string :subject
      t.string :title
      t.string :name
      t.string :phone_number
      t.string :email
      t.timestamps
    end
  end
end
