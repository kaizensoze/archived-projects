class CreateJobApplications < ActiveRecord::Migration
  def change
    create_table :job_applications do |t|
      t.string :full_name
      t.string :email
      t.string :phone
      t.string :current_company

      t.timestamps
    end
  end
end
