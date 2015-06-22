class CreateHelpNowItems < ActiveRecord::Migration
  def change
    create_table :help_now_items do |t|
      t.string :title
      t.string :body
      t.string :phone_number
      t.timestamps
    end
  end
end
