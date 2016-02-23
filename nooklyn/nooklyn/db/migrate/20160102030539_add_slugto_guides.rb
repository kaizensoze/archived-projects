class AddSlugtoGuides < ActiveRecord::Migration
  def change
    add_column :guides, :slug, :string
  end
end
