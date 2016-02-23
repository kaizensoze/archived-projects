class AddIsThumbToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :is_thumb, :boolean
  end
end
