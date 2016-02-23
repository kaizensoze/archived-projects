module Matrix
  class AgentsController < MatrixBaseController
    load_resource except: [:index, :hire, :probation]
    authorize_resource except: :index

    def index
      @agents = Agent.employees.page(params[:page]).per(100).order(first_name: :asc)
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @agents }
      end
    end

    def hire
      @agents = Agent.non_employees.page(params[:page]).per(100).order(created_at: :desc)
      render :index
    end

    def probation
      @agents = Agent.probation_employees.employees.page(params[:page]).per(100).order(created_at: :desc)
      render :index
    end

    def place_on_probation
      # @agent = Agent.find(params[:id])
      @agent.on_probation = true
      @agent.save(validate: false)
      respond_to do |format|
        format.html { redirect_to matrix_agents_path }
        format.json { head :no_content }
      end
    end

    def remove_from_probation
      # @agent = Agent.find(params[:id])
      @agent.on_probation = false
      @agent.save(validate: false)
      respond_to do |format|
        format.html { redirect_to matrix_agents_path }
        format.json { head :no_content }
      end
    end

    def place_on_suspension
      # @agent = Agent.find(params[:id])
      @agent.suspended = true
      @agent.save(validate: false)
      respond_to do |format|
        format.html { redirect_to matrix_agents_path }
        format.json { head :no_content }
      end
    end

    def remove_from_suspension
      # @agent = Agent.find(params[:id])
      @agent.suspended = false
      @agent.save(validate: false)
      respond_to do |format|
        format.html { redirect_to matrix_agents_path }
        format.json { head :no_content }
      end
    end


    def employ
      # @agent = Agent.find(params[:id])
      @agent.employee = true
      @agent.save(validate: false)
      respond_to do |format|
        format.html { redirect_to matrix_agents_path }
        format.json { head :no_content }
      end
    end

    def fire
      # @agent = Agent.find(params[:id])
      @agent.employee = false
      @agent.on_probation = false
      @agent.suspended = false
      @agent.save(validate: false)
      respond_to do |format|
        format.html { redirect_to matrix_agents_path }
        format.json { head :no_content }
      end
    end

    def stats
      query = AgentQueries::ResponseTimeList.new
      @agent_stats = query.list
    end

  end
end
