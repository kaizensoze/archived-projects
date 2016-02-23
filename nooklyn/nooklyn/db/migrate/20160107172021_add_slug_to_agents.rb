class AddSlugToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :slug, :string
  end
end
