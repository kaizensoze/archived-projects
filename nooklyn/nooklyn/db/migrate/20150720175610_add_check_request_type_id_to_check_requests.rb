class AddCheckRequestTypeIdToCheckRequests < ActiveRecord::Migration
  def change
    add_column :check_requests, :check_request_type_id, :integer
  end
end
