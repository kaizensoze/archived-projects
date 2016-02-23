class AddDescriptionToDeposit < ActiveRecord::Migration
  def change
    add_column :deposits, :description, :text
  end
end
