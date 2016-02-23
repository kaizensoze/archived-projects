describe GuideStoriesController, type: :controller do
  context "with any agent" do
    it "displays all guide stories" do
      get :index

      expect(response).to render_template :index
    end

    it "displays a particular story" do
      story = create(:guide_story)
      get :show, id: story.id

      expect(assigns(:guide_story)).to eq story
      expect(response).to render_template :show
    end

    it "cannot create a story" do
      get :new

      expect(response).to redirect_to root_path
    end

    it "cannot edit a story" do
      get :edit, id: create(:guide_story).id

      expect(response).to redirect_to root_path
    end
  end

  context "when agent is a super admin" do
    before :each do
      sign_in_as(create(:agent, super_admin: true))
    end

    it "displays form to create a story" do
      get :new

      expect(assigns(:guide_story)).to be_a_new GuideStory
      expect(response).to render_template :new
    end

    it "creates a new story" do
      story = build(:guide_story, title: "Central Cafe")
      post :create, guide_story: story.attributes

      expect(response).to redirect_to guide_path(story.guide)
      expect(GuideStory.find_by(title: "Central Cafe")).not_to be_nil
    end

    it "displays form to update a story" do
      story = create(:guide_story)
      get :edit, id: story.id

      expect(assigns(:guide_story)).to eq story
      expect(response).to render_template :edit
    end

    it "updates a story" do
      story = create(:guide_story)
      put :update, id: story.id, guide_story: story.attributes.merge(title: "Amancay's Diner")

      story.reload
      expect(story.title).to eq "Amancay's Diner"
      expect(response).to render_template :show
    end

    it "deletes a story" do
      story = create(:guide_story)
      delete :destroy, id: story.id

      expect(GuideStory.find_by(id: story.id)).to be_nil
      expect(response).to redirect_to guide_path(story.guide)
    end
  end
end
