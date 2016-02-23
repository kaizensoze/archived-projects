class AddEmailNotificationsToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :email_notifications, :bool, default: true
  end
end
