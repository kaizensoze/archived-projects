class OfficesController < ApplicationController
  load_and_authorize_resource
  respond_to :html

  def index
    respond_with(@offices)
  end

  def show
    respond_with(@office)
  end

  def new
    respond_with(@office)
  end

  def edit
  end

  def create
    @office.save
    respond_with(@office)
  end

  def update
    @office.update(office_params)
    respond_with(@office)
  end

  def destroy
    @office.destroy
    respond_with(@office)
  end

  private

  def office_params
    params.require(:office).permit(:name, :address_line_one, :address_line_two, :city, :state, :zip_code)
  end
end
