class AddDeviceTokenToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :device_token, :string
  end
end
