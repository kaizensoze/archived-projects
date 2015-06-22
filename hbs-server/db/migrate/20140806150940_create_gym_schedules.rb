class CreateGymSchedules < ActiveRecord::Migration
  def change
    create_table :gym_schedules do |t|
      t.date :date, null: false
      t.string :summary, null: false
      t.text :body, null: false
      t.integer :admin_user_id
      t.timestamps
    end

    add_index :gym_schedules, :date, unique: true
  end
end
