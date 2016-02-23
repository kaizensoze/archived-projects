class AddIsContactableToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :is_contactable, :boolean, :default => false
  end
end
