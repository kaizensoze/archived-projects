class Cms::HelpNowItemsController < ApplicationController
  before_action :authenticate_admin_user!

  layout 'cms'

  def index
    @help_now_items = HelpNowItem.order(:sort_order)
  end

  def new
    @help_now_item = HelpNowItem.new
  end

  def create
    @help_now_item = HelpNowItem.new(help_now_params)
    if @help_now_item.save
      flash[:notice] = "Help Now item saved."
      redirect_to cms_help_now_items_path
    end
  end

  def edit
    @help_now_item = HelpNowItem.find(params[:id])
    render :new
  end

  def update
    @help_now_item = HelpNowItem.find(params[:id])
    if @help_now_item.update_attributes(help_now_params)
      flash[:notice] = "Help Now item updated."
      redirect_to cms_help_now_items_path
    end
  end

  def destroy
    @help_now_item = HelpNowItem.find(params[:id])
    if @help_now_item.destroy
      flash[:notice] = "Help Now item deleted."
      redirect_to cms_help_now_items_path
    end
  end

  def sort
    params[:new_sort_order].each do |id, new_sort_order|
      help_now_item = HelpNowItem.find(id)
      help_now_item.sort_order = new_sort_order
      help_now_item.save
    end

    respond_to do |format|
      format.all { render :nothing => true, :status => 200 }
    end
  end

  def help_now_params
    params.require(:help_now_item).permit!
  end
end
