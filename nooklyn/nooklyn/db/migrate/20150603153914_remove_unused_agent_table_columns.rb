class RemoveUnusedAgentTableColumns < ActiveRecord::Migration
  def change
    remove_column :agents, :username
    remove_column :agents, :password
    remove_column :agents, :location
  end
end
