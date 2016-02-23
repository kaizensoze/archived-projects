class RenameIsAdminOnAgents < ActiveRecord::Migration
  def change
    rename_column :agents, :is_admin, :admin
  end
end
