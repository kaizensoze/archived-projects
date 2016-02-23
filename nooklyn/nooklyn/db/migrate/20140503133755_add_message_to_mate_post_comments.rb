class AddMessageToMatePostComments < ActiveRecord::Migration
  def change
    add_column :mate_post_comments, :message, :text
  end
end
