FactoryGirl.define do
  factory :location_category do
    name "Quiet Spots"
    sequence(:slug) {|n| "#{n}_locations"}
    image_file_name "nightlife.jpg"
    image_content_type "image/jpg"
    featured true
  end
end
