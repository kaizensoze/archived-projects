class AddFlagsToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :on_vacation, :boolean, default: false
    add_column :agents, :read_only_admin, :boolean, default: false
    add_column :agents, :region_id, :integer
  end
end
