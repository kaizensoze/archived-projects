class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :username
      t.string :password
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.boolean :is_admin

      t.timestamps
    end
  end
end
