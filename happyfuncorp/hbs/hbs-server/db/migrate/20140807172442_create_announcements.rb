class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.string :summary, null: false
      t.string :headline, null: false
      t.string :image
      t.text :body, null: false
      t.string :location
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :has_button
      t.string :button_text
      t.string :button_link
      t.boolean :active, default: true
      t.integer :sort_order
      t.integer :admin_user_id
      t.timestamps
    end

    add_index :announcements, :sort_order
  end
end
