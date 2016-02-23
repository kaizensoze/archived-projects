FactoryGirl.define do
  factory :mate_post_like do
    mate_post
    agent
  end

  factory :room_post_like do
    room_post
    agent
  end
end
