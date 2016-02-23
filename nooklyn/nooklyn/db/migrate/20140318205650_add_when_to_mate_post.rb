class AddWhenToMatePost < ActiveRecord::Migration
  def change
    add_column :mate_posts, :when, :datetime
  end
end
