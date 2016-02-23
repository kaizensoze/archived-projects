class AddPrivateProfileToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :private_profile, :boolean, :default => false
  end
end
