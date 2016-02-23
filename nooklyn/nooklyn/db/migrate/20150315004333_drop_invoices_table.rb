class DropInvoicesTable < ActiveRecord::Migration
  def up
    drop_table :invoices
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
