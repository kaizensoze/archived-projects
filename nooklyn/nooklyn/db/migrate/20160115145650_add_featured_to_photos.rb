class AddFeaturedToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :featured, :boolean, default: false
  end
end
