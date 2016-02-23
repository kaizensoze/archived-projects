class ChangeDefaultPrimaryphotoToSsl < ActiveRecord::Migration
  def change
    change_column :listings, :primaryphoto, :string, :default => "https://s3.amazonaws.com/nooklyn-pro/square/1/forent.jpeg"
  end
end
