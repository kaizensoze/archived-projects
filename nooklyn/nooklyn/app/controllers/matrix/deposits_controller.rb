module Matrix
  class DepositsController < MatrixBaseController
    authorize_resource
    before_action :set_deposit, only: [:show, :edit, :update, :destroy]
    before_action :load_agents
    before_action :load_deposit_statuses, only: [:new, :edit, :create, :update]
    before_action :load_offices, only: [:new, :edit, :create, :update]

    # GET /deposits
    # GET /deposits.json
    def index
      @deposits = Deposit.pending
                         .active_deposits
                         .with_agent(current_agent)
                         .includes(:transactions, :clients, :office, :listing_agent, :sales_agent)
                         .order(updated_at: :desc)

      if params[:address_search]
        @deposits = Deposit.all.where('address ILIKE ?', "%#{params[:address_search]}%")
      end

      if params[:client_search]
        @deposits = Deposit.all.joins(:clients)
          .where('deposit_clients.name ILIKE ?', "%#{params[:client_search]}%")
      end
    end

    def refunded
      @deposits = Deposit.refunded
                         .with_agent(current_agent)
                         .includes(:transactions, :office, :listing_agent, :sales_agent)
                         .order(updated_at: :desc)
      render :index
    end

    def signed_and_approved
      @deposits = Deposit.signed_and_approved
                         .with_agent(current_agent)
                         .includes(:transactions, :office, :listing_agent, :sales_agent)
                         .order(updated_at: :desc)
      render :index
    end

    def backed_out_deposits
      @deposits = Deposit.backed_out
                         .with_agent(current_agent)
                         .includes(:transactions, :office, :listing_agent, :sales_agent)
                         .order(updated_at: :desc)
      render :index
    end

    def mark_as_refund
      @deposit = Deposit.find(params[:id])
      @deposit.refund = true
      @deposit.save
      respond_to do |format|
        format.html { redirect_to matrix_deposits_path, notice: 'Deposit is now refunded.' }
      end
    end

    # GET /deposits/1
    # GET /deposits/1.json
    def show
      @deposit = Deposit.find(params[:id])
      @conversation = Conversation.where(context_url: request.original_url)
        .with_agent(current_agent)
        .select('conversations.*', 'conversation_participants.unread_messages AS unread')
        .order(updated_at: :desc)
        .first
      @conversation ||= Conversation.new
      @transactions_total = @deposit.transactions.sum(:amount)
    end

    # GET /deposits/new
    def new
      @deposit = Deposit.new
    end

    # GET /deposits/1/edit
    def edit
    end

    # POST /deposits
    # POST /deposits.json
    def create
      @deposit = Deposit.new(deposit_params)
      respond_to do |format|
        if @deposit.save
          format.html { redirect_to matrix_deposit_path(@deposit), notice: 'Deposit was successfully created.' }
          format.json { render :show, status: :created, location: @deposit }
        else
          format.html { render :new }
          format.json { render json: @deposit.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /deposits/1
    # PATCH/PUT /deposits/1.json
    def update
      respond_to do |format|
        if @deposit.update(deposit_params)
          format.html { redirect_to matrix_deposit_path(@deposit), notice: 'Deposit was successfully updated.' }
          format.json { render json: {}, status: :ok, location: matrix_deposit_path(@deposit) }
        else
          format.html { render :edit }
          format.json { render json: @deposit.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /deposits/1
    # DELETE /deposits/1.json
    def destroy
      @deposit.destroy
      respond_to do |format|
        format.html { redirect_to matrix_deposits_url, notice: 'Deposit was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_deposit
        @deposit = Deposit.find(params[:id])
      end

      def load_agents
        @agents ||= Agent.employees.order(first_name: :asc)
      end

      def load_deposit_statuses
        @deposit_statuses ||= DepositStatus.order(name: :asc)
      end

      def load_offices
        @offices ||= Office.order(name: :asc)
      end


      # Never trust parameters from the scary internet, only allow the white list through.
      def deposit_params
        params.require(:deposit).permit(:address,
                                        :unit,
                                        :listing_agent_id,
                                        :sales_agent_id,
                                        :other_sales_agent_id,
                                        :training_agent_id,
                                        :apartment_price,
                                        :offer_price,
                                        :when,
                                        :length_of_lease,
                                        :landlord_llc,
                                        :deposit_status_id,
                                        :office_id,
                                        :description,
                                        :credit_check,
                                        :refund,
                                        :creator_id,
                                        :owner_pays,
                                        :total_broker_fee,
                                        :full_address)
      end
  end
end