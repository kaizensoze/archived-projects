class CreateLocationPhotos < ActiveRecord::Migration
  def change
    create_table :location_photos do |t|
      t.timestamps null: false
    end
  end
end
