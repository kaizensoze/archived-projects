class AddPhotoTagToListings < ActiveRecord::Migration
  def up
    add_column :listings, :photo_tag, :string
  end
  
  def down
    remove_column :listings, :photo_tag
  end
end
