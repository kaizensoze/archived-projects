class ChangeDefaultPrimaryphoto < ActiveRecord::Migration
  def up
  	change_column :listings, :primaryphoto, :string, :default => "http://s3.amazonaws.com/nooklyn-pro/square/1/forent.jpeg"
  end

  def down
  	change_column :listings, :primaryphoto, :string, :default => nil
  end
end
