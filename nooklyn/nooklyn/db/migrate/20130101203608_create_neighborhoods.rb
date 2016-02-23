class CreateNeighborhoods < ActiveRecord::Migration
  def change
    create_table :neighborhoods do |t|
      t.string :name
      t.string :tag
      t.string :borough
      t.string :subway_lines

      t.timestamps
    end
  end
end
