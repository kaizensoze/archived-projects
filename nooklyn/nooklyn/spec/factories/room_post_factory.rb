FactoryGirl.define do
  factory :room_post do
    price 1000
    description "It's a room."
    image_file_name "room_post.jpg"
    image_content_type "image/jpg"
    sequence(:when) {|n| Time.now + n.days }
    latitude 23.2
    longitude 445.2

    agent
    neighborhood

    trait :with_room do
      after_create do |post|
        create(:room, room_post_id: post.id)
      end
    end
  end

  factory :room do
    sequence(:picture_file_name) {|n| "photo#{n}.jpg" }
    picture_content_type "image/jpg"
    room_category
  end

  factory :room_category
end
