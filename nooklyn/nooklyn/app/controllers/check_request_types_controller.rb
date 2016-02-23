class CheckRequestTypesController < ApplicationController
  before_action :set_check_request_type, only: [:show, :edit, :update, :destroy]
  authorize_resource
  layout 'nklyn-pages'

  # GET /check_request_types
  # GET /check_request_types.json
  def index
    @check_request_types = CheckRequestType.all
  end

  # GET /check_request_types/1
  # GET /check_request_types/1.json
  def show
    @check_request_type = CheckRequestType.find(params[:id])
    @check_request_types = CheckRequestType.order(name: :asc)
    @check_requests = @check_request_type.check_requests.pending_approval
                                                         .pending_rejection
                                                         .with_agent(current_agent)
                                                         .page(params[:page])
                                                         .per(50)
                                                        .order(verified: :desc, updated_at: :desc)
  end

  # GET /check_request_types/new
  def new
    @check_request_type = CheckRequestType.new
  end

  # GET /check_request_types/1/edit
  def edit
  end

  # POST /check_request_types
  # POST /check_request_types.json
  def create
    @check_request_type = CheckRequestType.new(check_request_type_params)

    respond_to do |format|
      if @check_request_type.save
        format.html { redirect_to @check_request_type, notice: 'Check request type was successfully created.' }
        format.json { render :show, status: :created, location: @check_request_type }
      else
        format.html { render :new }
        format.json { render json: @check_request_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /check_request_types/1
  # PATCH/PUT /check_request_types/1.json
  def update
    respond_to do |format|
      if @check_request_type.update(check_request_type_params)
        format.html { redirect_to @check_request_type, notice: 'Check request type was successfully updated.' }
        format.json { render :show, status: :ok, location: @check_request_type }
      else
        format.html { render :edit }
        format.json { render json: @check_request_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /check_request_types/1
  # DELETE /check_request_types/1.json
  def destroy
    @check_request_type.destroy
    respond_to do |format|
      format.html { redirect_to check_request_types_url, notice: 'Check request type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_check_request_type
      @check_request_type = CheckRequestType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def check_request_type_params
      params.require(:check_request_type).permit(:name, :active)
    end
end
