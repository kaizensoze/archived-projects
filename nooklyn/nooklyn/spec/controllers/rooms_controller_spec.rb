describe RoomsController, type: :controller do
  before :each do
    @agent = create(:agent, employee: false)
    sign_in_as(@agent)
  end

  context "when room is attached to agent's own post" do
    before :each do
      @rp = create(:room_post, agent: @agent)
    end

    it "displays form to create a room" do
      get :new, room_post_id: @rp.id

      expect(response).to render_template :new
      expect(assigns(:room_post)).to eq @rp
      expect(assigns(:room).room_post_id).to eq @rp.id
    end

    it "creates a room" do
      room = build(:room)
      post :create, room_post_id: @rp.id, room: room.attributes.merge(picture: fixture_file_upload("photo.jpg", "image/jpg"))

      expect(response).to redirect_to rm_settings_path
      expect(assigns(:room_post)).to eq @rp
      expect(assigns(:room).room_post).to eq @rp
      expect(@rp.rooms.count).to eq 1
    end

    describe "managing rooms" do
      before :each do
        @room = create(:room, room_post: @rp)
      end

      it "displays form to edit the room" do
        get :edit, room_post_id: @rp.id, id: @room.id

        expect(response).to render_template :edit
      end

      it "updates a room" do
        cat = create(:room_category)
        put :update, room_post_id: @rp.id, id: @room.id, room: @room.attributes.merge(room_category_id: cat.id)

        @room.reload
        expect(response).to redirect_to rm_settings_path
        expect(@room.room_category).to eq cat
      end

      it "destroys a room" do
        delete :destroy, room_post_id: @rp.id, id: @room.id

        expect(response).to redirect_to rooms_url
        expect(Room.find_by(id: @room.id)).to be_nil
      end
    end
  end

  context "when room is attached to another agent's post" do
    before :each do
      @rp = create(:room_post)
    end

    it "cannot create a room" do
      get :new, room_post_id: @rp.id

      expect(response).to redirect_to root_path
    end

    it "cannot edit a room" do
      room = create(:room, room_post: @rp)
      get :edit, room_post_id: @rp.id, id: room.id

      expect(response).to redirect_to root_path
    end
  end
end
