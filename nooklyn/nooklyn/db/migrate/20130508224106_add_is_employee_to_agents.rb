class AddIsEmployeeToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :is_employee, :boolean
  end
end
