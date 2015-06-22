class Cms::GymSchedulesController < ApplicationController
  before_action :authenticate_admin_user!
  
  layout 'cms'

  def index
    @gym_schedules = GymSchedule.order(date: :desc)
  end

  def new
    @gym_schedule = GymSchedule.new
  end

  def create
    @gym_schedule = GymSchedule.new(gym_schedule_params)
    @gym_schedule.admin_user = current_admin_user
    if @gym_schedule.save
      flash[:notice] = "Gym schedule saved."
      redirect_to cms_gym_schedules_path
    else
      render :new
    end
  end

  def edit
    @gym_schedule = GymSchedule.find(params[:id])
    render :new
  end

  def update
    @gym_schedule = GymSchedule.find(params[:id])
    if @gym_schedule.update_attributes(gym_schedule_params)
      flash[:notice] = "Gym schedule updated."
      redirect_to cms_gym_schedules_path
    else
      render :new
    end
  end

  def destroy
    @gym_schedule = GymSchedule.find(params[:id])
    if @gym_schedule.destroy
      flash[:notice] = "Gym schedule deleted."
      redirect_to cms_gym_schedules_path
    end
  end

  def gym_schedule_params
    params.require(:gym_schedule).permit!
  end
end
