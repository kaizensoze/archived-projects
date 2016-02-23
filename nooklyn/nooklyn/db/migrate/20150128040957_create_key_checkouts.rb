class CreateKeyCheckouts < ActiveRecord::Migration
  def change
    create_table :key_checkouts do |t|
      t.text :message
      t.integer :agent_id
      t.boolean :returned, :default => false

      t.timestamps null: false
    end
  end
end
