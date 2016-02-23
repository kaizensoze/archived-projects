class AddIsBearToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :is_bear, :boolean, :default => false
  end
end
