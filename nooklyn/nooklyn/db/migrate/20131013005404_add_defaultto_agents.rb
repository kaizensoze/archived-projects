class AddDefaulttoAgents < ActiveRecord::Migration
  def change
    change_column :agents, :probation, :boolean, :default => false
  end
end
