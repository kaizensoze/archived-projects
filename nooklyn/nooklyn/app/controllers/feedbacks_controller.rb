class FeedbacksController < ApplicationController
  load_resource except: :index
  authorize_resource
  layout "nklyn-pages"

  # GET /feedbacks
  # GET /feedbacks.json
  def index
    @feedbacks = Feedback.all.order("created_at desc")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @feedbacks }
    end
  end

  # GET /feedbacks/1
  # GET /feedbacks/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @feedback }
    end
  end

  # GET /feedbacks/new
  # GET /feedbacks/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @feedback }
    end
  end

  # GET /feedbacks/1/edit
  def edit
  end

  # POST /feedbacks
  # POST /feedbacks.json
  def create
    respond_to do |format|
      if @feedback.save
        FeedbackMailer.feedback_message(@feedback.email, @feedback.message, @feedback.name).deliver_later
        format.html { redirect_to root_path, notice: 'Thank you. Your Feedback is appreciated.' }
        format.json { render json: @feedback, status: :created, location: @feedback }
      else
        format.html { render action: "new" }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /feedbacks/1
  # PUT /feedbacks/1.json
  def update
    respond_to do |format|
      if @feedback.update_attributes(feedback_params)
        format.html { redirect_to @feedback, notice: 'Feedback was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.json
  def destroy
    @feedback.destroy

    respond_to do |format|
      format.html { redirect_to feedbacks_url }
      format.json { head :no_content }
    end
  end

  private

  def feedback_params
    params.require(:feedback)
          .permit(:email, :message, :name)
  end

end
