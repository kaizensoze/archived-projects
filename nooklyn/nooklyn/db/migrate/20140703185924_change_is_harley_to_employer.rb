class ChangeIsHarleyToEmployer < ActiveRecord::Migration
  def change
    rename_column :agents, :is_harley, :employer
  end
end
