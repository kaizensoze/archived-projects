class AddOnProbationToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :on_probation, :boolean, :default => false
  end
end
