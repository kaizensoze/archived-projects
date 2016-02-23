class CreateGuides < ActiveRecord::Migration
  def change
    create_table :guides do |t|
      t.integer :neighborhood_id
      t.string :title
      t.text :description
      t.text :pull_quote
      t.string :pull_quote_author

      t.timestamps null: false
    end
  end
end
