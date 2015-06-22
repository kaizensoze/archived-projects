class AddSubjectIdToWhoToCallItems < ActiveRecord::Migration
  def change
    add_column :who_to_call_items, :who_to_call_subject_id, :integer
    remove_column :who_to_call_items, :subject
  end
end
