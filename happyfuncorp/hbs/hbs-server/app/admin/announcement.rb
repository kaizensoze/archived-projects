ActiveAdmin.register Announcement do
  menu :priority => 5, :label => "Don't Miss"

  index :title => "Don't Miss"

  controller do
    def index
      params[:order] = "sort_order"
      super
    end
  end
end
