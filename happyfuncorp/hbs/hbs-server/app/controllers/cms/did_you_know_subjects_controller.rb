class Cms::DidYouKnowSubjectsController < ApplicationController
  before_action :authenticate_admin_user!

  layout 'cms'

  def index
    @did_you_know_subjects = DidYouKnowSubject.order(:sort_order)
  end

  def new
    @did_you_know_subject = DidYouKnowSubject.new
  end

  def create
    @did_you_know_subject = DidYouKnowSubject.new(did_you_know_params)
    if @did_you_know_subject.save
      flash[:notice] = "Did you Know subject saved."
      redirect_to cms_did_you_know_subjects_path
    end
  end

  def show
    @did_you_know_subject = DidYouKnowSubject.find(params[:id])
    @did_you_know_items = @did_you_know_subject.did_you_know_items.order(:sort_order)
  end

  def edit
    @did_you_know_subject = DidYouKnowSubject.find(params[:id])
    render :new
  end

  def update
    @did_you_know_subject = DidYouKnowSubject.find(params[:id])
    if @did_you_know_subject.update_attributes(did_you_know_params)
      flash[:notice] = "Did you Know subject updated."
      redirect_to cms_did_you_know_subjects_path
    end
  end

  def destroy
    @did_you_know_subject = DidYouKnowSubject.find(params[:id])
    if @did_you_know_subject.destroy
      flash[:notice] = "Did you Know subject deleted."
      redirect_to cms_did_you_know_subjects_path
    end
  end

  def sort
    params[:new_sort_order].each do |id, new_sort_order|
      did_you_know_subject = DidYouKnowSubject.find(id)
      did_you_know_subject.sort_order = new_sort_order
      did_you_know_subject.save
    end

    respond_to do |format|
      format.all { render :nothing => true, :status => 200 }
    end
  end

  def did_you_know_params
    params.require(:did_you_know_subject).permit!
  end
end
