class CreateDepositAttachments < ActiveRecord::Migration
  def change
    create_table :deposit_attachments do |t|
      t.integer :agent_id
      t.integer :deposit_id

      t.timestamps null: false
    end
  end
end
