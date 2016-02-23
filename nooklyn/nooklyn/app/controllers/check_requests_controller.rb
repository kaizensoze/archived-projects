class CheckRequestsController < ApplicationController
  before_action :set_check_request, only: [:show, :edit, :update, :destroy, :approve, :reject, :verify]
  layout 'nklyn-pages'
  before_action :load_types, only: [:new, :edit, :create, :update]
  before_action :load_agents, only: [:new, :edit, :create, :update]
  authorize_resource

  # GET /check_requests
  # GET /check_requests.json
  def index
    @check_requests = CheckRequest.pending_approval
                                  .pending_rejection
                                  .with_agent(current_agent)
                                  .page(params[:page])
                                  .per(50)
                                  .order(verified: :desc, updated_at: :desc)

    @check_request_types = CheckRequestType.order(name: :asc)
    if params[:address_search]
      @check_requests = CheckRequest.where('apartment_address ILIKE ?', "%#{params[:address_search]}%").page(params[:page]).per(50)
    end

    if params[:vendor_search]
      @check_requests = CheckRequest.where('name ILIKE ?', "%#{params[:vendor_search]}%").page(params[:page]).per(50)
    end
  end

  def approved
    @check_requests = CheckRequest.already_approved
                                  .with_agent(current_agent)
                                  .page(params[:page])
                                  .per(50)
                                  .order(updated_at: :desc)
    render :index
  end

  def verified
    @check_requests = CheckRequest.already_verified
                                  .with_agent(current_agent)
                                  .page(params[:page])
                                  .per(50)
                                  .order(updated_at: :desc)
    render :index
  end

  def rejected
    @check_requests = CheckRequest.already_rejected
                                  .with_agent(current_agent)
                                  .page(params[:page])
                                  .per(50)
                                  .order(updated_at: :desc)
    render :index
  end

  # GET /check_requests/1
  # GET /check_requests/1.json
  def show
  end

  # GET /check_requests/new
  def new
    @check_request = CheckRequest.new
  end

  # GET /check_requests/1/edit
  def edit
  end

  # POST /check_requests
  # POST /check_requests.json
  def create
    @check_request = CheckRequest.new(check_request_params)

    respond_to do |format|
      if @check_request.save
        format.html { redirect_to check_requests_path, notice: 'Check request was successfully created.' }
        format.json { render :show, status: :created, location: @check_request }
      else
        format.html { render :new }
        format.json { render json: @check_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /check_requests/1
  # PATCH/PUT /check_requests/1.json
  def update
    respond_to do |format|
      if @check_request.update(check_request_params)
        format.html { redirect_to check_requests_path, notice: 'Check request was successfully updated.' }
        format.json { render :show, status: :ok, location: @check_request }
      else
        format.html { render :edit }
        format.json { render json: @check_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def approve
    respond_to do |format|
      if @check_request.update_attributes(approved: true)
        CheckRequestMailer.check_approved_notification(@check_request.agent, @check_request.name, @check_request.apartment_address, @check_request.amount).deliver_later
        format.html { redirect_to check_requests_path, notice: 'Check has been approved!' }
        format.json { render json: @check_request }
      else
        format.html { render action: "edit", notice: "Server error, try again." }
        format.json { render json: @check_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def verify
    respond_to do |format|
      if @check_request.update_attributes(verified: true)
        format.html { redirect_to check_requests_path, notice: 'Check has been verified!' }
        format.json { render json: @check_request }
      else
        format.html { render action: "edit", notice: "Server error, try again." }
        format.json { render json: @check_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def reject
    respond_to do |format|
      if @check_request.update_attributes(rejected: true)
        CheckRequestMailer.check_rejected_notification(@check_request.agent, @check_request.name, @check_request.apartment_address, @check_request.amount).deliver_later
        format.html { redirect_to check_requests_path, notice: 'Check has been rejected.' }
        format.json { render json: @check_request }
      else
        format.html { render action: "edit", notice: "Server error, try again." }
        format.json { render json: @check_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /check_requests/1
  # DELETE /check_requests/1.json
  def destroy
    @check_request.destroy
    respond_to do |format|
      format.html { redirect_to check_requests_url, notice: 'Check request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def load_agents
      @agents ||= Agent.employees.order(first_name: :asc)
    end

    def load_types
      @check_types ||= CheckRequestType.usable_types.order(name: :asc)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_check_request
      @check_request = CheckRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def check_request_params
      params.require(:check_request).permit(:name, :apartment_address, :unit, :amount, :check_date, :approved, :notes, :check_request_type_id, :agent_id)
    end
end
