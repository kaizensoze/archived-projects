class CreateBackgroundImages < ActiveRecord::Migration
  def change
    create_table :background_images do |t|
      t.string    :image, null: false
      t.boolean   :active, default: true
      t.integer :sort_order
      t.timestamps
    end

    add_index :background_images, :sort_order
  end
end
