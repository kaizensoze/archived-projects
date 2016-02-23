class CreateOffices < ActiveRecord::Migration
  def change
    create_table :offices do |t|
      t.string :name
      t.string :address_line_one
      t.string :address_line_two
      t.string :city
      t.string :state
      t.string :zip_code

      t.timestamps null: false
    end
  end
end
