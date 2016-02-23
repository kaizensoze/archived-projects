FactoryGirl.define do
  factory :comment do
    name "Jonathan Norrell"
    phone "(234) 343 2321"
    sequence(:email) {|n| "jonathan#{n}@norrell.com" }
    message "Cool!"

    commentable factory: :mate_post
  end
end
