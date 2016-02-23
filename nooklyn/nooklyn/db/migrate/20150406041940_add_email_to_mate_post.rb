class AddEmailToMatePost < ActiveRecord::Migration
  def change
    add_column :mate_posts, :email, :string
  end
end
