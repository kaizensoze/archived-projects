class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.date :date, null: false
      t.string :summary, null: false
      t.text :body, null: false
      t.integer :admin_user_id
      t.timestamps
    end

    add_index :menus, :date, unique: true
  end
end
