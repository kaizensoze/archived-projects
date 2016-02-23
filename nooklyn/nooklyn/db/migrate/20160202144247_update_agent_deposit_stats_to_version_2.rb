class UpdateAgentDepositStatsToVersion2 < ActiveRecord::Migration
  def change
    update_view :agent_deposit_stats, version: 2, revert_to_version: 1
  end
end
