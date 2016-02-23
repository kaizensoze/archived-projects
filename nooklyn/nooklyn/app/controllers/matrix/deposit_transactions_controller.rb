module Matrix
  class DepositTransactionsController < MatrixBaseController
    authorize_resource
    before_action :load_offices, only: [:new, :edit, :create, :update]
    before_action :set_deposit_transaction, only: [:edit, :update]

    # GET /deposit_transactions
    # GET /deposit_transactions.json
    def index
      @transactions = DepositTransaction.page(params[:page]).per(500).includes(:office, :deposit).order("created_at desc")
      if params[:name_search]
        @transactions = DepositTransaction.where('client_name ILIKE ?', "%#{params[:name_search]}%").page(params[:page]).per(150)
      end
    end

    # GET /deposit_transactions/1
    # GET /deposit_transactions/1.json
    def show
    end

    # GET /deposit_transactions/new
    def new
      @deposit = Deposit.find(params[:deposit_id])
      @deposit_transaction = @deposit.transactions.build
    end

    # GET /deposit_transactions/1/edit
    def edit
    end

    # POST /deposit_transactions
    # POST /deposit_transactions.json
    def create
      @deposit = Deposit.find(params[:deposit_id])
      @deposit_transaction = @deposit.transactions.build(deposit_transaction_params)

      respond_to do |format|
        if @deposit_transaction.save
          format.html { redirect_to matrix_deposit_path(@deposit), notice: 'Deposit transaction was successfully created.' }
          format.json { render :show, status: :created, location: @deposit_transaction }
        else
          format.html { render :new }
          format.json { render json: @deposit_transaction.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /deposit_transactions/1
    # PATCH/PUT /deposit_transactions/1.json
    def update

      respond_to do |format|
        if @deposit_transaction.update(deposit_transaction_params)
          format.html { redirect_to matrix_deposits_path, notice: 'Deposit transaction was successfully updated.' }
          format.json { render :show, status: :ok, location: @deposit_transaction }
        else
          format.html { render :edit }
          format.json { render json: @deposit_transaction.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /deposit_transactions/1
    # DELETE /deposit_transactions/1.json
    def destroy
      @deposit_transaction.destroy
      respond_to do |format|
        format.html { redirect_to deposit_transactions_url, notice: 'Deposit transaction was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_deposit_transaction
        @deposit_transaction = DepositTransaction.find(params[:id])
      end

      def load_offices
        @offices ||= Office.order(name: :asc)
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def deposit_transaction_params
        params.require(:deposit_transaction).permit(:amount, :deposit_transaction_type, :client_name, :creator_id, :office_id, :notes)
      end
  end
end
