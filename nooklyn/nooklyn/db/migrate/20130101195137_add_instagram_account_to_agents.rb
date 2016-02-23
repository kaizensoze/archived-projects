class AddInstagramAccountToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :instagram_account, :string
  end
end
