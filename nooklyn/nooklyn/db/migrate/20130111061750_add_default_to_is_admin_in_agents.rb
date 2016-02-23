class AddDefaultToIsAdminInAgents < ActiveRecord::Migration
  	def up
    	change_column :agents, :is_admin, :boolean, :default => false
	end

	def down
	    change_column :agents, :is_admin, :boolean, :default => nil
	end
end
