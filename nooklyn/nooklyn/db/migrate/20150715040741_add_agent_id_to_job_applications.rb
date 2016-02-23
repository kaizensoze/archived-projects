class AddAgentIdToJobApplications < ActiveRecord::Migration
  def change
    add_column :job_applications, :agent_id, :integer
  end
end
