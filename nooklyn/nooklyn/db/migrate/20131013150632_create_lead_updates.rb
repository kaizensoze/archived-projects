class CreateLeadUpdates < ActiveRecord::Migration
  def change
    create_table :lead_updates do |t|
      t.text :message
      t.integer :lead_id
      t.string :ip_address
      t.string :user_agent
      t.integer :agent_id

      t.timestamps
    end
  end
end
