FactoryGirl.define do
  factory :mate_post do
    price 950
    description "Cool!"
    image_file_name "mate_post.jpg"
    image_content_type "image/jpg"
    sequence(:when) {|n| Time.now + n.days }

    agent
    neighborhood
  end
end
