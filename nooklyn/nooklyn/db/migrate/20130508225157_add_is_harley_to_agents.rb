class AddIsHarleyToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :is_harley, :boolean, :default => false
  end
end
