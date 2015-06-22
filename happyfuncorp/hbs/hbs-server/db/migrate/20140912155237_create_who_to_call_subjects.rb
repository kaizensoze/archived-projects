class CreateWhoToCallSubjects < ActiveRecord::Migration
  def change
    create_table :who_to_call_subjects do |t|
      t.string :subject, null: false
      t.integer :sort_order
      t.timestamps
    end

    add_index :who_to_call_subjects, :subject, unique: true
    add_index :who_to_call_subjects, :sort_order
  end
end
