class LeadsController < ApplicationController
  load_resource except: [:index, :all, :upcomingmonth, :upcomingtwomonth, :private_lead]
  authorize_resource

  # GET /leads
  # GET /leads.json
  def index
    @leads = Lead.upcoming
                 .includes(:updates, :agents, :agent)
                 .order(created_at: :desc)
                 .page(params[:page])
                 .per(50)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @leads }
    end
  end

  # GET /leads/1
  # GET /leads/1.json
  def show
    @agents = Agent.employees.order('created_at ASC')

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lead }
    end
  end

  # GET /leads/new
  # GET /leads/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @lead }
    end
  end

  # GET /leads/1/edit
  def edit
  end

  # POST /leads
  # POST /leads.json
  def create
    if @lead.save
      respond_to do |format|
        format.html do
          if can? :read, Lead
            redirect_to @lead, notice: 'Lead Created!'
          else
            redirect_to contact_path, notice: 'An agent will follow up with you soon.'
          end
        end

        format.json { render json: @lead, status: :created, location: @lead }
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /leads/1
  # PUT /leads/1.json
  def update
    respond_to do |format|
      if @lead.update_attributes(lead_params)
        format.html { redirect_to @lead, notice: 'Lead was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.json
  def destroy
    @lead.destroy

    respond_to do |format|
      format.html { redirect_to leads_url }
      format.json { head :no_content }
    end
  end

  private

  def lead_params
    params.require(:lead)
          .permit(:agent_id, :comments, :contacted, :email, :full_name, :is_landlord, :max_price, :min_price, :move_in, :pets, :phone)
  end
end
