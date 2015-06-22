class AddSubjectIdToDidYouKnowItems < ActiveRecord::Migration
  def change
    add_column :did_you_know_items, :did_you_know_subject_id, :integer
    remove_column :did_you_know_items, :subject
  end
end
