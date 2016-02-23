module Matrix
  class DepositStatusesController < MatrixBaseController
    before_action :set_deposit_status, only: [:show, :edit, :update, :destroy]
    before_action :load_agents

    # GET /deposit_statuses
    # GET /deposit_statuses.json
    def index
      @deposit_statuses = DepositStatus.all
    end

    # GET /deposit_statuses/1
    # GET /deposit_statuses/1.json
    def show
      @deposit_status = DepositStatus.find(params[:id])
      @deposits = @deposit_status.deposits
                         .with_agent(current_agent)
                         .includes(:transactions, :office, :listing_agent, :sales_agent)
                         .order(updated_at: :desc)
    end

    # GET /deposit_statuses/new
    def new
      @deposit_status = DepositStatus.new
    end

    # GET /deposit_statuses/1/edit
    def edit
    end

    # POST /deposit_statuses
    # POST /deposit_statuses.json
    def create
      @deposit_status = DepositStatus.new(deposit_status_params)

      respond_to do |format|
        if @deposit_status.save
          format.html { redirect_to matrix_deposit_statuses_path, notice: 'Deposit status was successfully created.' }
          format.json { render :show, status: :created, location: @deposit_status }
        else
          format.html { render :new }
          format.json { render json: @deposit_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /deposit_statuses/1
    # PATCH/PUT /deposit_statuses/1.json
    def update
      respond_to do |format|
        if @deposit_status.update(deposit_status_params)
          format.html { redirect_to matrix_deposit_statuses_path, notice: 'Deposit status was successfully updated.' }
          format.json { render :show, status: :ok, location: @deposit_status }
        else
          format.html { render :edit }
          format.json { render json: @deposit_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /deposit_statuses/1
    # DELETE /deposit_statuses/1.json
    def destroy
      @deposit_status.destroy
      respond_to do |format|
        format.html { redirect_to matrix_deposit_statuses_path, notice: 'Deposit status was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

      def load_agents
        @agents ||= Agent.employees.order(first_name: :asc)
      end
      # Use callbacks to share common setup or constraints between actions.
      def set_deposit_status
        @deposit_status = DepositStatus.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def deposit_status_params
        params.require(:deposit_status).permit(:name, :description, :active)
      end
  end
end
