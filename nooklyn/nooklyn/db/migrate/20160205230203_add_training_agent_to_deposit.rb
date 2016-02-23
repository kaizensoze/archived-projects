class AddTrainingAgentToDeposit < ActiveRecord::Migration
  def change
    add_column :deposits, :training_agent_id, :integer
  end
end
