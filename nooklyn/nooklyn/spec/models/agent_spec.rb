require 'cancan/matchers'

describe Agent do
  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should have_attached_file(:profile_picture) }
    it { should validate_attachment_content_type(:profile_picture).
                allowing("image/jpg", "image/png").
                rejecting("application/pdf") }
  end

  describe "associations" do
    it { should have_many :hearts }
    it { should have_many(:liked_listings).class_name("Listing") }
    it { should have_many(:sales_agent_listings).class_name("Listing") }
    it { should have_many(:listing_agent_listings).class_name("Listing") }
    it { should have_many(:mate_posts) }
    it { should have_many(:mate_post_likes) }
    it { should have_many(:liked_mates).through(:mate_post_likes) }
    it { should have_many(:room_posts) }
    it { should have_many(:room_post_likes) }
    it { should have_many(:liked_rooms).through(:room_post_likes) }
    it { should have_many(:listings_collections) }
  end

  describe "scopes" do
    before :each do
      @recent = create(:agent, created_at: 2.weeks.ago)
      @nonemp = create(:agent, employee: false)
      @prob = create(:agent, on_probation: true)
      @old_picture = create(:agent, profile_picture_updated_at: 2.years.ago)
      @agents = Agent.all
    end

    it "finds agents from the previous month" do
      expect(@agents.lastmonth).to include @recent
    end

    it "finds non-employees" do
      expect(@agents.non_employees).to include @nonemp
    end

    it "finds agents on probation" do
      expect(@agents.probation_employees).to include @prob
    end

    it "finds agents not on probation" do
      expect(@agents.not_on_probation).not_to include @prob
    end

    it "finds agents with profile pictures" do
      expect(@agents.has_profile_picture).not_to include @old_picture
    end
  end

  describe "#name" do
    it "combines first and last names" do
      expect(build(:agent).name).to eq "Jonathan Norrell"
    end
  end

  describe "#find_for_facebook_oauth" do
    before :all do
      @auth_struct = Struct.new("Auth",
                                :provider,
                                :uid,
                                :credentials,
                                :info,
                                :extra)
      @credentials = Struct.new("Credentials", :token, :expires_at)
      @info = Struct.new("Info", :image, :email)
      @extra = Struct.new("Extra", :raw_info)
      @raw_info = Struct.new("RawInfo", :gender, :link, :first_name, :last_name)
    end

    before :each do
      @auth = @auth_struct.new("facebook",
                               "999",
                               @credentials.new("token", Time.now),
                               @info.new,
                               @extra.new(@raw_info.new))
    end

    it "returns a registered agent when signed in resource is present" do
      agent = create(:agent, provider: "facebook", uid: "999")
      found_resource = Agent.find_for_facebook_oauth(@auth)
      expect(found_resource.email).to eq agent.email
      expect(found_resource.provider).to eq "facebook"
    end

    it "returns a registered agent without signed in resource" do
      expect(Agent.find_for_facebook_oauth(@auth).provider).to eq "facebook"
    end

    it "finds the agent by provider and uid" do
      agent = create(:agent, provider: "facebook", uid: "999")
      found_resource = Agent.find_for_facebook_oauth(@auth)
      expect(found_resource.id).to eq agent.id
    end

    it "finds the agent by email" do
      agent = create(:agent)
      @auth.info.email = agent.email
      found_resource = Agent.find_for_facebook_oauth(@auth)
      expect(found_resource.id).to eq agent.id
    end
  end

  describe "abilities" do
    let(:ability) { Ability.new(agent) }

    context "when agent is a super admin" do
      let(:agent) { build_stubbed(:agent, super_admin: true) }

      it "can do anything" do
        expect(ability).to be_able_to(:manage, :all)
      end

      it "can destroy a listing" do
        expect(ability).to be_able_to(:destroy, Listing)
      end
    end

    context "when agent is an employee" do
      let(:agent) { build_stubbed(:agent, employee: true) }

      it "can create listings" do
        expect(ability).to be_able_to(:create, Listing)
      end

      it "can read listings" do
        expect(ability).to be_able_to(:read, Listing)
      end

      it "can create and update lots of stuff" do
        [Lead, Photo, Location, Listing].each do |model|
          expect(ability).to be_able_to(:create, model)
          expect(ability).to be_able_to(:update, model)
        end
      end

      it "can check out keys" do
        expect(ability).to be_able_to(:create, KeyCheckout)
        expect(ability).to be_able_to(:return, KeyCheckout)
      end

      it "can read and update leads" do
        expect(ability).to be_able_to(:read, Lead)
        expect(ability).to be_able_to(:update, Lead)
      end

      it "cannot destroy anything but photos" do
        expect(ability).not_to be_able_to(:destroy, Lead)
        expect(ability).to be_able_to(:destroy, Photo)
        expect(ability).not_to be_able_to(:destroy, Location)
        expect(ability).not_to be_able_to(:destroy, KeyCheckout)
        expect(ability).not_to be_able_to(:destroy, GuideStory)
      end
    end

    context "when agent has been suspended" do
      let(:agent) { build_stubbed(:agent, suspended: true) }

      it "can't do anything to listings" do
        expect(ability).not_to be_able_to(:read, Listing)
      end

      it "does not have employee privileges" do
        [Location, Photo, KeyCheckout].each do |model|
          [:create, :edit, :update].each do |action|
            expect(ability).not_to be_able_to(action, model)
          end
        end
      end

      it "can create but not read or update leads" do
        expect(ability).to be_able_to(:create, Lead)
        expect(ability).not_to be_able_to(:update, Lead)
        expect(ability).not_to be_able_to(:read, Lead)
      end
    end

    context "when agent is an employer" do
      let(:agent) { build_stubbed(:agent, employer: true) }

      it "can read job applications" do
        expect(ability).to be_able_to(:read, JobApplication)
      end

      it "can hire and fire agents" do
        expect(ability).to be_able_to(:employ, Agent)
        expect(ability).to be_able_to(:hire, Agent)
        expect(ability).to be_able_to(:fire, Agent)
      end

      it "can place agents on probation" do
        expect(ability).to be_able_to(:place_on_probation, Agent)
        expect(ability).to be_able_to(:remove_from_probation, Agent)
      end
    end

    context "for all agents" do
      let(:agent) { build_stubbed(:agent, employee: false) }

      it "can view mates in a neighborhood" do
        expect(ability).to be_able_to(:mates, Neighborhood)
      end

      it "can like posts" do
        expect(ability).to be_able_to(:like, RoomPost)
        expect(ability).to be_able_to(:unlike, MatePost)
      end

      it "can like listings" do
        expect(ability).to be_able_to(:like, Listing)
        expect(ability).to be_able_to(:unlike, Listing)
      end

      it "can comment on posts" do
        expect(ability).to be_able_to(:create, RoomPostComment)
        expect(ability).to be_able_to(:create, MatePostComment)
      end

      it "can update their own posts" do
        expect(ability).to be_able_to(:update, build_stubbed(:mate_post, agent: agent))
        expect(ability).not_to be_able_to(:update, build_stubbed(:mate_post))
        expect(ability).to be_able_to(:update, build_stubbed(:room_post, agent: agent))
        expect(ability).not_to be_able_to(:update, build_stubbed(:room_post))
      end

      it "can create posts" do
        expect(ability).to be_able_to(:create, RoomPost)
        expect(ability).to be_able_to(:create, MatePost)
      end

      it "can create and update rooms" do
        expect(ability).to be_able_to(:create, Room)
        expect(ability).to be_able_to(:update, Room)
      end

      it "can create job applications" do
        expect(ability).to be_able_to(:create, JobApplication)
      end
    end

    context "agent is a guest" do
      let(:agent) { nil }

      it "can view listings" do
        expect(ability).to be_able_to(:read, Listing)
        expect(ability).to be_able_to(:rentals, Listing)
        expect(ability).to be_able_to(:sales, Listing)
      end

      it "can view neighborhoods" do
        expect(ability).to be_able_to(:read, Neighborhood)
        expect(ability).to be_able_to(:rooms, Neighborhood)
        expect(ability).to be_able_to(:locations, Neighborhood)
      end

      it "can view lots of things" do
        [Agent, RoomPost, Guide, GuideStory, Location, LocationCategory].each do |model|
          expect(ability).to be_able_to(:read, model)
        end
      end

      it "can create but not read leads" do
        expect(ability).to be_able_to(:create, Lead)
        expect(ability).not_to be_able_to(:read, Lead)
      end

      it "can create feedback" do
        expect(ability).to be_able_to(:create, Feedback)
      end
    end
  end
end
