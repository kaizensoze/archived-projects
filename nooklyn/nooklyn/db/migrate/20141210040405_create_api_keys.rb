class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.references :agent, index: true
      t.string :token

      t.timestamps
    end

    add_index :api_keys, :token, unique: true
  end
end
