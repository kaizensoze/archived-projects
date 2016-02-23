class DropDealsTable < ActiveRecord::Migration
  def up
  	drop_table :deals
  end

  def down
  	raise ActiveRecord::IrreversibleMigration
  end
end
