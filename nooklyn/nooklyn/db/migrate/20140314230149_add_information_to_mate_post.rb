class AddInformationToMatePost < ActiveRecord::Migration
  def change
    add_column :mate_posts, :ip_address, :string
    add_column :mate_posts, :user_agent, :string
  end
end
