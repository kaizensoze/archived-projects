class CreateCheckRequestTypes < ActiveRecord::Migration
  def change
    create_table :check_request_types do |t|
      t.string :name
      t.boolean :active

      t.timestamps null: false
    end
  end
end
