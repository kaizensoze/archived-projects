FactoryGirl.define do
  factory :listing do
    sequence(:title) {|n| "Cool Apartment #{n}" }
    address "225 Morgan Ave"
    latitude 5.5
    longitude 5.5
    description "Amazing apartment with windows and chairs and everything"
    amenities "sofas, microwave"
    bathrooms 1.3
    bedrooms 3.4
    residential true
    rental true
    status "Available"
    exclusive false
    pets true
    price 120000.00
    utilities "cable, heat, wifi"
    image_updated_at { 1.day.ago }
    landlord_contact "Joel Munt"
    subway_line "L"
    access "all"

    neighborhood
    association :listing_agent, factory: :agent
    sales_agent_id { listing_agent_id }
  end
end
