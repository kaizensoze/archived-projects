class CreateHearts < ActiveRecord::Migration
  def change
    create_table :hearts do |t|
      t.integer :agent_id
      t.integer :listing_id

      t.timestamps
    end
  end
end
