class PollsChangeActiveId < ActiveRecord::Migration
  def change
    change_column :polls, :active_id, :string
  end
end
