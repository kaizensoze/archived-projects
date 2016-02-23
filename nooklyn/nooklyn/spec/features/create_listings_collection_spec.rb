describe "creating a listings collection", type: :feature do
  before :each do
    @agent = create(:agent, employee: false)
    visit 'login'
    fill_in "Email", with: @agent.email
    fill_in "Password", with: "password"
    click_button "Login"
  end

  it "creates a listing collection" do
    visit 'listings_collections/new'

    fill_in "Name", with: "Cool Apartments"
    fill_in "Description", with: "These are some cool apartments I'm showing"

    click_button("Submit")
    collection = ListingsCollection.first

    expect(current_path).to eq listings_collection_path(collection)
  end
end
