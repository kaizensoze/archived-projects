class CreateListingIgnores < ActiveRecord::Migration
  def change
    create_table :listing_ignores do |t|
      t.integer :agent_id
      t.integer :listing_id

      t.timestamps
    end
  end
end
