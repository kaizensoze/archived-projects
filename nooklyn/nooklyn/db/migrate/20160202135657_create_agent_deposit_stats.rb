class CreateAgentDepositStats < ActiveRecord::Migration
  def change
    create_view :agent_deposit_stats
  end
end
