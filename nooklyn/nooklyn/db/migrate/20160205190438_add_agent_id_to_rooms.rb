class AddAgentIdToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :agent_id, :integer
  end
end
