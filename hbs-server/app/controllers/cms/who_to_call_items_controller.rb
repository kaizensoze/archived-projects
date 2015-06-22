class Cms::WhoToCallItemsController < ApplicationController
  before_action :authenticate_admin_user!

  layout 'cms'

  def new
    @who_to_call_subject = WhoToCallSubject.find(params[:who_to_call_subject_id])
    @who_to_call_item = WhoToCallItem.new
  end

  def create
    @who_to_call_subject = WhoToCallSubject.find(params[:who_to_call_subject_id])
    @who_to_call_item = WhoToCallItem.new(who_to_call_params)
    @who_to_call_item.who_to_call_subject_id = @who_to_call_subject.id
    if @who_to_call_item.save
      flash[:notice] = "Who to Call item saved."
      redirect_to cms_who_to_call_subject_path(@who_to_call_subject)
    end
  end

  def edit
    @who_to_call_subject = WhoToCallSubject.find(params[:who_to_call_subject_id])
    @who_to_call_item = WhoToCallItem.find(params[:id])
    render :new
  end

  def update
    @who_to_call_subject = WhoToCallSubject.find(params[:who_to_call_subject_id])
    @who_to_call_item = WhoToCallItem.find(params[:id])
    if @who_to_call_item.update_attributes(who_to_call_params)
      flash[:notice] = "Who to Call item updated."
      redirect_to cms_who_to_call_subject_path(@who_to_call_subject)
    end
  end

  def destroy
    @who_to_call_subject = WhoToCallSubject.find(params[:who_to_call_subject_id])
    @who_to_call_item = WhoToCallItem.find(params[:id])
    if @who_to_call_item.destroy
      flash[:notice] = "Who to Call item deleted."
      redirect_to cms_who_to_call_subject_path(@who_to_call_subject)
    end
  end

  def sort
    params[:new_sort_order].each do |id, new_sort_order|
      who_to_call_item = WhoToCallItem.find(id)
      who_to_call_item.sort_order = new_sort_order
      who_to_call_item.save
    end

    respond_to do |format|
      format.all { render :nothing => true, :status => 200 }
    end
  end

  def who_to_call_params
    params.require(:who_to_call_item).permit!
  end
end
