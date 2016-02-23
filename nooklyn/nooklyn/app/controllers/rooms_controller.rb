class RoomsController < ApplicationController
  load_resource :room_post
  load_and_authorize_resource :room
  before_action :load_room_categories, only: [:new, :edit, :create]

  # GET /rooms
  def index
  end

  # GET /rooms/1
  def show
  end

  # GET /rooms/new
  def new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  def create
    if @room.save
      redirect_to rm_settings_path, notice: 'Room was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /rooms/1
  def update
    if @room.update(room_params)
      redirect_to rm_settings_path, notice: 'Room was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /rooms/1
  def destroy
    @room.destroy
    redirect_to rm_settings_path, notice: 'Room was successfully destroyed.'
  end

  private

  def load_room_categories
    @room_categories = RoomCategory.all
  end

  def room_params
    params.require(:room).permit(:room_category_id, :picture, :agent_id, :room_post_id)
  end
end
