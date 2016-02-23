class RemoveUnusedColumnsFromAgents < ActiveRecord::Migration
  def change
    remove_column :agents, :is_contactable, :boolean
    remove_column :agents, :instagram_account, :string
  end
end
