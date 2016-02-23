class RenameMarketingAgentId < ActiveRecord::Migration
  def change
    rename_column :listings, :marketing_agent_id, :sales_agent_id
  end
end
