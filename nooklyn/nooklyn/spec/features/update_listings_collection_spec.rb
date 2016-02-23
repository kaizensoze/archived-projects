describe "updating a listings collection", type: :feature do
  before :each do
    @agent = create(:agent, employee: false)
    @collection = create(:listings_collection, agent: @agent)
    visit 'login'
    fill_in "Email", with: @agent.email
    fill_in "Password", with: "password"
    click_button "Login"
  end

  it "updates a collection" do
    pending("listing collection slug vs. id issue needs to be fixed")

    visit edit_listings_collection_path(@collection.id)

    fill_in "Name", with: "New Name"
    click_button("Submit")
    @collection.reload

    expect(current_path).to eq listings_collection_path(@collection.id)
    expect(@collection.name).to eq "New Name"
    expect(@collection.slug).to eq "collection-1"
  end
end
