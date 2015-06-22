class AddPendingConfirmedUserDeviceId < ActiveRecord::Migration
  def change
    # device_id -> pending_device_id
    rename_column :users, :device_id, :pending_device_id

    # add confirmed_device_id
    add_column :users, :confirmed_device_id, :string
    add_index :users, :confirmed_device_id
  end
end
