class AddSortOrderToDidYouKnowItems < ActiveRecord::Migration
  def change
    add_column :did_you_know_items, :sort_order, :integer

    add_index :did_you_know_items, :sort_order
  end
end
