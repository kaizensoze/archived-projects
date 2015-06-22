class Cms::WhoToCallSubjectsController < ApplicationController
  before_action :authenticate_admin_user!

  layout 'cms'

  def index
    @who_to_call_subjects = WhoToCallSubject.order(:sort_order)
  end

  def new
    @who_to_call_subject = WhoToCallSubject.new
  end

  def create
    @who_to_call_subject = WhoToCallSubject.new(who_to_call_params)
    if @who_to_call_subject.save
      flash[:notice] = "Who to Call subject saved."
      redirect_to cms_who_to_call_subjects_path
    end
  end

  def show
    @who_to_call_subject = WhoToCallSubject.find(params[:id])
    @who_to_call_items = @who_to_call_subject.who_to_call_items.order(:sort_order)
  end

  def edit
    @who_to_call_subject = WhoToCallSubject.find(params[:id])
    render :new
  end

  def update
    @who_to_call_subject = WhoToCallSubject.find(params[:id])
    if @who_to_call_subject.update_attributes(who_to_call_params)
      flash[:notice] = "Who to Call subject updated."
      redirect_to cms_who_to_call_subjects_path
    end
  end

  def destroy
    @who_to_call_subject = WhoToCallSubject.find(params[:id])
    if @who_to_call_subject.destroy
      flash[:notice] = "Who to Call subject deleted."
      redirect_to cms_who_to_call_subjects_path
    end
  end

  def sort
    params[:new_sort_order].each do |id, new_sort_order|
      who_to_call_subject = WhoToCallSubject.find(id)
      who_to_call_subject.sort_order = new_sort_order
      who_to_call_subject.save
    end

    respond_to do |format|
      format.all { render :nothing => true, :status => 200 }
    end
  end

  def who_to_call_params
    params.require(:who_to_call_subject).permit!
  end
end
