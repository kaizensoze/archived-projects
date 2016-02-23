class ChangeIsBeartoGod < ActiveRecord::Migration
  def change
    rename_column :agents, :is_bear, :god
  end
end
