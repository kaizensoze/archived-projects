class RemoveTagFromPhotos < ActiveRecord::Migration
  def up
    remove_column :photos, :tag
  end

  def down
    add_column :photos, :tag, :string
  end
end
