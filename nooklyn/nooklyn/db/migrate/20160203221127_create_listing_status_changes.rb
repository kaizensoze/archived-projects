class CreateListingStatusChanges < ActiveRecord::Migration
  def change
    create_table :listing_status_changes do |t|
      t.references :listing, index: true, foreign_key: true
      t.references :agent, index: true, foreign_key: true
      t.integer :status

      t.timestamps null: false
    end
  end
end
