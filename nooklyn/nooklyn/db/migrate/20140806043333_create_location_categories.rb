class CreateLocationCategories < ActiveRecord::Migration
  def change
    create_table :location_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
