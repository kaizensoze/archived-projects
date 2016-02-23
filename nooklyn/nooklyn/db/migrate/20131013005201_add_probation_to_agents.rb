class AddProbationToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :probation, :boolean
  end
end
