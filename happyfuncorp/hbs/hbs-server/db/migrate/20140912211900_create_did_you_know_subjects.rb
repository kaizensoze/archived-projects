class CreateDidYouKnowSubjects < ActiveRecord::Migration
  def change
    create_table :did_you_know_subjects do |t|
      t.string :subject, null: false
      t.integer :sort_order
      t.timestamps
    end

    add_index :did_you_know_subjects, :subject, unique: true
    add_index :did_you_know_subjects, :sort_order
  end
end
