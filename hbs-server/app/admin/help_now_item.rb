ActiveAdmin.register HelpNowItem do
  menu priority: 6, label: "Help Now"

  permit_params :title, :body, :phone_number

  index title: "Help Now" do
    selectable_column
    column :title
    column :body
    column :phone_number
    actions
  end
end
