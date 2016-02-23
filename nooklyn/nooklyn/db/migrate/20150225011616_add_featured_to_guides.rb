class AddFeaturedToGuides < ActiveRecord::Migration
  def change
    add_column :guides, :featured, :boolean, :default => false
  end
end
