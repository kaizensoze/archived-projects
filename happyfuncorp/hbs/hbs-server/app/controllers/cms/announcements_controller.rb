class Cms::AnnouncementsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :fix_params, :only => [:create, :update]
  
  layout 'cms'

  def index
    @announcements = Announcement.order(:sort_order)
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.admin_user = current_admin_user
    if @announcement.save
      flash[:notice] = "Announcement saved."
      redirect_to cms_announcements_path
    else
      render :new
    end
  end

  def edit
    @announcement = Announcement.find(params[:id])
    render :new
  end

  def update
    @announcement = Announcement.find(params[:id])
    if @announcement.update_attributes(announcement_params)
      flash[:notice] = "Announcement updated."
      redirect_to cms_announcements_path
    else
      render :new
    end
  end

  def destroy
    @announcement = Announcement.find(params[:id])
    if @announcement.destroy
      flash[:notice] = "Announcement deleted."
      redirect_to cms_announcements_path
    end
  end

  def sort
    params[:new_sort_order].each do |id, new_sort_order|
      announcement = Announcement.find(id)
      announcement.sort_order = new_sort_order
      announcement.save
    end

    respond_to do |format|
      format.all { render :nothing => true, :status => 200 }
    end
  end

  def set_active_inactive
    @announcement = Announcement.find(params[:id])
    @announcement.active = !@announcement.active
    @announcement.save

    respond_to do |format|
      format.js
    end
  end

  def announcement_params
    params.require(:announcement).permit!
  end

  def fix_params
    start_date = Date.parse(params[:announcement].delete(:start_time)) rescue nil
    if start_date.nil?
      params[:announcement]['start_time(1i)'] = ""
      params[:announcement]['start_time(2i)'] = ""
      params[:announcement]['start_time(3i)'] = ""
      params[:announcement]['start_time(4i)'] = ""
      params[:announcement]['start_time(5i)'] = ""
    else
      params[:announcement].merge!({
        'start_time(1i)' => start_date.year.to_s,
        'start_time(2i)' => start_date.month.to_s,
        'start_time(3i)' => start_date.day.to_s,
      })
    end

    end_date = Date.parse(params[:announcement].delete(:end_time)) rescue nil
    if end_date.nil?
      params[:announcement]['end_time(1i)'] = ""
      params[:announcement]['end_time(2i)'] = ""
      params[:announcement]['end_time(3i)'] = ""
      params[:announcement]['end_time(4i)'] = ""
      params[:announcement]['end_time(5i)'] = ""
    else
      params[:announcement].merge!({
        'end_time(1i)' => end_date.year.to_s,
        'end_time(2i)' => end_date.month.to_s,
        'end_time(3i)' => end_date.day.to_s
      })
    end
  end
end
