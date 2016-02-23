class RemoveProbationFromAgents < ActiveRecord::Migration
  def up
    remove_column :agents, :probation
  end

  def down
    add_column :agents, :probation, :boolean
  end
end
