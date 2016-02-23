class AddPositionToJobApplications < ActiveRecord::Migration
  def change
    add_column :job_applications, :position, :string
  end
end
