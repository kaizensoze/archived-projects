ActiveAdmin.register BackgroundImage do
  permit_params :image

  menu :priority => 2

  controller do
    def index
      params[:order] = "sort_order"
      super
    end
  end

  index do
    selectable_column
    id_column
    column :sort_order
    column :image
    column :active
    actions
  end

  show do |background_image|
    attributes_table do
      row :id
      row :sort_order
      row :image do
        image_tag background_image.image
      end
      row :active
      row :created_at
      row :updated_at
    end
  end
end
