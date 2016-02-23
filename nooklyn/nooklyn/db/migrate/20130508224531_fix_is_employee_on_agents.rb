class FixIsEmployeeOnAgents < ActiveRecord::Migration
  def up
  	 change_column :agents, :is_employee, :boolean, :default => false
  end

  def down
  	change_column :agents, :is_employee, :boolean, :default => nil
  end
end
