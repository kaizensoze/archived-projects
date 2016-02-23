module Matrix
  class KeyCheckoutsController < MatrixBaseController
    load_resource except: :index
    authorize_resource
    before_action :load_agents, only: [:new, :edit, :create, :update]
    before_action :load_offices, only: [:new, :edit, :create, :update]
    respond_to :html

    def index
      @key_checkouts = KeyCheckout.page(params[:page])
                                  .per(50)
                                  .order(created_at: :desc)
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      if @key_checkout.save
        redirect_to matrix_key_checkouts_path, notice: 'Thank you for checking out the key!'
      else
        render action: "new"
      end
    end

    def update
      @key_checkout.update(key_checkout_params)
      @offices = Office.all
      render :show
    end

    def destroy
      @key_checkout.destroy
      redirect_to matrix_key_checkouts_path, notice: 'Checkout successfully deleted'
    end

    def return
      @key_checkout.returned = true
      @key_checkout.save
      respond_to do |format|
        format.html { redirect_to matrix_key_checkouts_path }
        format.json { head :no_content }
      end
    end

    private

    def load_agents
      @agents ||= Agent.employees.order(first_name: :asc)
    end

    def load_offices
      @offices ||= Office.all
    end

    def key_checkout_params
      params.require(:key_checkout).permit(:message, :agent_id, :returned, :office_id)
    end
  end
end