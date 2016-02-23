module Matrix
  class DepositClientsController < MatrixBaseController
    authorize_resource
    before_action :set_deposit_client, only: [:edit, :update]
    # GET /deposit_clients
    # GET /deposit_clients.json
    def index
      @deposit_clients = DepositClient.all
    end

    # GET /deposit_clients/1
    # GET /deposit_clients/1.json
    def show
    end

    # GET /deposit_clients/new
    def new
      @deposit = Deposit.find(params[:deposit_id])
      @deposit_client = @deposit.clients.build
    end

    # GET /deposit_clients/1/edit
    def edit
    end

    # POST /deposit_clients
    # POST /deposit_clients.json
    def create
      @deposit = Deposit.find(params[:deposit_id])
      @deposit_client = @deposit.clients.build(deposit_client_params)

      respond_to do |format|
        if @deposit_client.save
          format.html { redirect_to matrix_deposit_path(@deposit), notice: 'Deposit client was successfully created.' }
          format.json { render :show, status: :created, location: @deposit_client }
        else
          format.html { render :new }
          format.json { render json: @deposit_client.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /deposit_clients/1
    # PATCH/PUT /deposit_clients/1.json
    def update
      respond_to do |format|
        if @deposit_client.update(deposit_client_params)
          format.html { redirect_to matrix_deposit_path(@deposit_client.deposit), notice: 'Deposit client was successfully updated.' }
          format.json { render :show, status: :ok, location: @deposit_client }
        else
          format.html { render :edit }
          format.json { render json: @deposit_client.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /deposit_clients/1
    # DELETE /deposit_clients/1.json
    def destroy
      @deposit_client.destroy
      respond_to do |format|
        format.html { redirect_to matrix_deposits_url, notice: 'Deposit client was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_deposit_client
        @deposit_client = DepositClient.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def deposit_client_params
        params.require(:deposit_client).permit(:name, :guarantor, :deposit_id, :creator_id)
      end
  end
end
