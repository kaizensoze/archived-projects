class AddDefaultToIsThumbInPhotos < ActiveRecord::Migration
  	def up
    	change_column :photos, :is_thumb, :boolean, :default => false
	end

	def down
	    change_column :photos, :is_thumb, :boolean, :default => nil
	end
end

