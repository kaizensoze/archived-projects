class AddSuspendedToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :suspended, :boolean, :default => false
  end
end
