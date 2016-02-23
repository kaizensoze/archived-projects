class AddContextUrlToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :context_url, :string, default: ''
  end
end
