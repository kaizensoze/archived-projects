class RenameUserSectionNumber < ActiveRecord::Migration
  def change
    rename_column :users, :section_number, :section
  end
end
