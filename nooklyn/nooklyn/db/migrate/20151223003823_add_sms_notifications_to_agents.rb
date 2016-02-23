class AddSmsNotificationsToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :sms_notifications, :bool, default: true
  end
end
