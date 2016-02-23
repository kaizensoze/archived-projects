describe JobApplicationsController, type: :controller do
  context "when agent is a guest" do
    it "can create a job application" do
      get :new

      expect(response).to render_template :new
    end
  end

  context "when agent is signed in" do
    before :each do
      sign_in_as(create(:agent, employee: false))
    end

    it "renders form to create a job application" do
      get :new

      expect(response).to render_template :new
    end

    it "creates a job application" do
      app = build(:job_application, full_name: "Peggy Olson")
      post :create, job_application: app.attributes.merge(resume: fixture_file_upload("resume.pdf", "application/pdf"))

      expect(JobApplication.find_by(full_name: "Peggy Olson")).not_to be_nil
      expect(response).to redirect_to jobs_path
    end

    it "cannot read job applications" do
      get :index

      expect(response).to redirect_to root_path
    end
  end

  context "when agent is an employer" do
    before :each do
      sign_in_as(create(:agent, employer: true))
    end

    it "can read job applications" do
      get :index

      expect(response).to render_template :index
    end

    it "cannot delete job applications" do
      app = create(:job_application, full_name: "Michael Ginsburg")
      delete :destroy, id: app.id

      expect(response).to redirect_to root_path
      expect(JobApplication.find_by(full_name: "Michael Ginsburg")).not_to be_nil
    end
  end

  context "when agent is a super admin" do
    before :each do
      sign_in_as(create(:agent, super_admin: true))
      @app = create(:job_application)
    end

    it "displays edit form" do
      get :edit, id: @app.id

      expect(response).to render_template :edit
    end

    it "updates a job application" do
      put :update, id: @app.id, job_application: @app.attributes.merge(full_name: "Johnny Mathis")
      @app.reload

      expect(@app.full_name).to eq "Johnny Mathis"
      expect(response).to redirect_to job_application_path(@app)
    end

    it "deletes a job application" do
      delete :destroy, id: @app.id

      expect(response).to redirect_to job_applications_url
      expect(JobApplication.find_by(id: @app.id)).to be_nil
    end
  end
end
