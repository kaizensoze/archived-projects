class AddConfirmableToDevise < ActiveRecord::Migration
  # Note: You can't use change, as Agent.update_all will fail in the down migration
  def up
    add_column :agents, :confirmation_token, :string
    add_column :agents, :confirmed_at, :datetime
    add_column :agents, :confirmation_sent_at, :datetime
    # add_column :agents, :unconfirmed_email, :string # Only if using reconfirmable
    add_index :agents, :confirmation_token, unique: true
    # Agent.reset_column_information # Need for some types of updates, but not for update_all.
    # To avoid a short time window between running the migration and updating all existing
    # agents as confirmed, do the following
    Agent.update_all(:confirmed_at => Time.now)
    # All existing user accounts should be able to log in after this.
  end

  def down
    remove_columns :agents, :confirmation_token, :confirmed_at, :confirmation_sent_at
    # remove_columns :agents, :unconfirmed_email # Only if using reconfirmable
  end
end
