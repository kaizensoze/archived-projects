class JobApplicationsController < ApplicationController
  load_and_authorize_resource

  # GET /job_applications
  # GET /job_applications.json
  def index
    @job_applications = JobApplication.order(created_at: :desc)
                       .page(params[:page])
                       .per(20)
  end

  # GET /job_applications/1
  # GET /job_applications/1.json
  def show
  end

  # GET /job_applications/new
  def new
  end

  # GET /job_applications/1/edit
  def edit
  end

  # POST /job_applications
  # POST /job_applications.json
  def create
    respond_to do |format|
      if @job_application.save
        JobApplicationMailer.job_application_message(@job_application.email, @job_application.phone, @job_application.full_name, @job_application.position).deliver_later
        format.html { redirect_to jobs_path, notice: 'Thank you! We will get back to you soon!' }
        format.json { render :show, status: :created, location: @job_application }
      else
        format.html { render :new }
        format.json { render json: @job_application.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /job_applications/1
  # PATCH/PUT /job_applications/1.json
  def update
    respond_to do |format|
      if @job_application.update(job_application_params)
        format.html { redirect_to @job_application, notice: 'Job application was successfully updated.' }
        format.json { render :show, status: :ok, location: @job_application }
      else
        format.html { render :edit }
        format.json { render json: @job_application.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /job_applications/1
  # DELETE /job_applications/1.json
  def destroy
    @job_application.destroy
    respond_to do |format|
      format.html { redirect_to job_applications_url, notice: 'Job application was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def claim
    @job_application.agent_id = current_agent.id
    @job_application.save
    respond_to do |format|
      format.html { redirect_to job_applications_path, notice: 'You have claimed this job application!' }
    end
  end

  private

  def job_application_params
    params.require(:job_application).permit(:full_name, :email, :phone, :current_company, :resume, :position)
  end
end
