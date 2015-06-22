class Cms::BackgroundImagesController < ApplicationController
  before_action :authenticate_admin_user!

  layout 'cms'

  def index
    @background_images = BackgroundImage.order(:sort_order)
  end

  def new
    @background_image = BackgroundImage.new
  end

  def create
    @background_image = BackgroundImage.new(background_image_params)
    if @background_image.save
      flash[:notice] = "Background image saved."
      redirect_to cms_background_images_path
    else
      flash[:alert] = 'Please select a valid image.'
      render 'new'
    end
  end

  def edit
    @background_image = BackgroundImage.find(params[:id])
    @error_message = session[:error_message]
    session.delete(:error_message)
    render :new
  end

  def update
    @background_image = BackgroundImage.find(params[:id])
    if @background_image.update_attributes(background_image_params)
      flash[:notice] = "Background image updated."
      redirect_to cms_background_images_path
    else
      if @background_image.errors
        error_message = @background_image.errors.full_messages
        session[:error_message] = error_message[0]
      end
      redirect_to edit_cms_background_image_path(@background_image)
    end
  end

  def destroy
    @background_image = BackgroundImage.find(params[:id])
    if @background_image.destroy
      flash[:notice] = "Background image deleted."
      redirect_to cms_background_images_path
    end
  end

  def sort
    params[:new_sort_order].each do |id, new_sort_order|
      background_image = BackgroundImage.find(id)
      background_image.sort_order = new_sort_order
      background_image.save
    end

    respond_to do |format|
      format.all { render :nothing => true, :status => 200 }
    end
  end

  def set_active_inactive
    @background_image = BackgroundImage.find(params[:id])

    num_active = BackgroundImage.where(active: true).size
    if @background_image.active && num_active <= 1
      render :nothing => true
      return
    end

    @background_image.active = !@background_image.active
    @background_image.save

    respond_to do |format|
      format.js
    end
  end

  def background_image_params
    params.require(:background_image).permit!
  end
end
