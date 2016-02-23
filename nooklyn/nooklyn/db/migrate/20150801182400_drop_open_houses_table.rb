class DropOpenHousesTable < ActiveRecord::Migration
 def up
    drop_table :open_houses
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
