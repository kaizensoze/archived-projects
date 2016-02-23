class AddRefundedToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :refund, :boolean, :default => false
  end
end
