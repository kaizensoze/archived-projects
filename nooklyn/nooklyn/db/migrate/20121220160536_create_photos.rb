class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :tag

      t.timestamps
    end
  end
end
