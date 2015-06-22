class Cms::MenusController < ApplicationController
  before_action :authenticate_admin_user!
  
  layout 'cms'

  def index
    @menus = Menu.order(date: :desc)
  end

  def new
    @menu = Menu.new
  end

  def create
    @menu = Menu.new(menu_params)
    @menu.admin_user = current_admin_user
    if @menu.save
      flash[:notice] = "Menu saved."
      redirect_to cms_menus_path
    else
      render :new
    end
  end

  def edit
    @menu = Menu.find(params[:id])
    render :new
  end

  def update
    @menu = Menu.find(params[:id])
    if @menu.update_attributes(menu_params)
      flash[:notice] = "Menu updated."
      redirect_to cms_menus_path
    else
      render :new
    end
  end

  def destroy
    @menu = Menu.find(params[:id])
    if @menu.destroy
      flash[:notice] = "Menu deleted."
      redirect_to cms_menus_path
    end
  end

  def menu_params
    params.require(:menu).permit!
  end
end
