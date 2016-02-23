class RoomCategoriesController < ApplicationController
  load_and_authorize_resource

  # GET /room_categories
  def index
  end

  # GET /room_categories/1
  def show
  end

  # GET /room_categories/new
  def new
  end

  # GET /room_categories/1/edit
  def edit
  end

  # POST /room_categories
  def create
    if @room_category.save
      redirect_to room_categories_path, notice: 'Room category was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /room_categories/1
  def update
    if @room_category.update(room_category_params)
      redirect_to @room_category, notice: 'Room category was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /room_categories/1
  def destroy
    @room_category.destroy
    redirect_to room_categories_url, notice: 'Room category was successfully destroyed.'
  end

  private

  def room_category_params
    params.require(:room_category).permit(:name)
  end
end
