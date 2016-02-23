class ChangeDefaultsOnMatePost < ActiveRecord::Migration
  def change
    change_column :mate_posts, :dogs, :boolean, :default => false
    change_column :mate_posts, :cats, :boolean, :default => false
  end
end
