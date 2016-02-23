class AddFacebookAuthToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :provider, :string
    add_column :agents, :uid, :string
    add_column :agents, :oauth_token, :string
    add_column :agents, :oauth_expires_at, :datetime
    add_column :agents, :image, :string
    add_column :agents, :facebook_url, :string
    add_column :agents, :location, :string
    add_column :agents, :gender, :string
  end
end
