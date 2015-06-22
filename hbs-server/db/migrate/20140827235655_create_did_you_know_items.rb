class CreateDidYouKnowItems < ActiveRecord::Migration
  def change
    create_table :did_you_know_items do |t|
      t.string :subject
      t.string :title
      t.string :website
      t.string :email
      t.string :phone_number
      t.timestamps
    end
  end
end
