class Cms::DidYouKnowItemsController < ApplicationController
  before_action :authenticate_admin_user!

  layout 'cms'

  def new
    @did_you_know_subject = DidYouKnowSubject.find(params[:did_you_know_subject_id])
    @did_you_know_item = DidYouKnowItem.new
  end

  def create
    @did_you_know_subject = DidYouKnowSubject.find(params[:did_you_know_subject_id])
    @did_you_know_item = DidYouKnowItem.new(did_you_know_params)
    @did_you_know_item.did_you_know_subject_id = @did_you_know_subject.id
    if @did_you_know_item.save
      flash[:notice] = "Did you Know item saved."
      redirect_to cms_did_you_know_subject_path(@did_you_know_subject)
    end
  end

  def edit
    @did_you_know_subject = DidYouKnowSubject.find(params[:did_you_know_subject_id])
    @did_you_know_item = DidYouKnowItem.find(params[:id])
    render :new
  end

  def update
    @did_you_know_subject = DidYouKnowSubject.find(params[:did_you_know_subject_id])
    @did_you_know_item = DidYouKnowItem.find(params[:id])
    if @did_you_know_item.update_attributes(did_you_know_params)
      flash[:notice] = "Did you Know item updated."
      redirect_to cms_did_you_know_subject_path(@did_you_know_subject)
    end
  end

  def destroy
    @did_you_know_subject = DidYouKnowSubject.find(params[:did_you_know_subject_id])
    @did_you_know_item = DidYouKnowItem.find(params[:id])
    if @did_you_know_item.destroy
      flash[:notice] = "Did you Know item deleted."
      redirect_to cms_did_you_know_subject_path(@did_you_know_subject)
    end
  end

  def sort
    params[:new_sort_order].each do |id, new_sort_order|
      did_you_know_item = DidYouKnowItem.find(id)
      did_you_know_item.sort_order = new_sort_order
      did_you_know_item.save
    end

    respond_to do |format|
      format.all { render :nothing => true, :status => 200 }
    end
  end

  def did_you_know_params
    params.require(:did_you_know_item).permit!
  end
end
