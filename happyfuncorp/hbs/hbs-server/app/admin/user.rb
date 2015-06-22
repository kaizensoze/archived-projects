ActiveAdmin.register User do
  menu :priority => 9

  permit_params [:email, :password, :password_confirmation, :first_name, :last_name, :type, :section, :class_year]

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :type
    column :pending_device_id
    column :confirmed_device_id
    column :auth_token
    column :section
    column :class_year
    column :confirmation_token
    column :confirmed_at
    actions
  end

  form do |f|
    f.inputs "User" do
      f.input :email, required: true
      f.input :password, required: true
      f.input :password_confirmation, required: true
      f.input :first_name
      f.input :last_name
      f.input :type
      f.input :section
      f.input :class_year
    end
    f.actions
  end

  before_create do |user|
    user.skip_confirmation!
  end

  before_save do |user|
    user.skip_reconfirmation!
  end

  before_update do |user|
    user.skip_reconfirmation!
  end
end
