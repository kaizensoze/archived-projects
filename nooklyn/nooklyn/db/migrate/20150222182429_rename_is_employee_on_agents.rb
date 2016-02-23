class RenameIsEmployeeOnAgents < ActiveRecord::Migration
  def change
    rename_column :agents, :is_employee, :employee
  end
end
