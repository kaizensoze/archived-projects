FactoryGirl.define do
  factory :photo do
    image_file_name "photo.jpg"
    image_content_type "image/jpg"

    trait :with_listing do
      listing
    end
  end
end
