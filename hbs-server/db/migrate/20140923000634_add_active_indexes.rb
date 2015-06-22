class AddActiveIndexes < ActiveRecord::Migration
  def change
    add_index :background_images, :active
    add_index :announcements, :active
  end
end
