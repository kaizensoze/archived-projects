class AddSortOrderToWhoToCallItems < ActiveRecord::Migration
  def change
    add_column :who_to_call_items, :sort_order, :integer

    add_index :who_to_call_items, :sort_order
  end
end
