class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.integer :room_category_id

      t.timestamps
    end
  end
end
