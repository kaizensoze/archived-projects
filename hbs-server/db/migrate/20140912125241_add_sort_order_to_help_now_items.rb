class AddSortOrderToHelpNowItems < ActiveRecord::Migration
  def change
    add_column :help_now_items, :sort_order, :integer

    add_index :help_now_items, :sort_order
  end
end
