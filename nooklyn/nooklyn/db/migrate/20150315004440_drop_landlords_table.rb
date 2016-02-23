class DropLandlordsTable < ActiveRecord::Migration
  def up
    drop_table :landlords
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
