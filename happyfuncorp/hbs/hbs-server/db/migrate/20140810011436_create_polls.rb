class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.integer :active_id
      t.timestamps
    end
  end
end
