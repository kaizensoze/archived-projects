class RenameGodOnAgents < ActiveRecord::Migration
  def change
    rename_column :agents, :god, :super_admin
  end
end
