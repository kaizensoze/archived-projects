ActiveAdmin.register DidYouKnowItem do
  menu priority: 8, label: "Did You Know"

  permit_params :subject, :title, :website, :email, :phone_number

  index title: "Did You Know" do
    selectable_column
    column :subject
    column :title
    column :website
    column :email
    column :phone_number
    actions
  end
end
