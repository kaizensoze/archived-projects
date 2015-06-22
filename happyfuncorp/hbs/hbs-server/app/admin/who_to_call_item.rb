ActiveAdmin.register WhoToCallItem do
  menu priority: 7, label: "Who To Call"

  permit_params :subject, :title, :name, :phone_number, :email

  index title: "Who To Call" do
    selectable_column
    column :subject
    column :title
    column :name
    column :phone_number
    column :email
    actions
  end
end
