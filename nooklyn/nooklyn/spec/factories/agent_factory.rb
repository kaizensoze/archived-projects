FactoryGirl.define do
  factory :agent do
    first_name "Jonathan"
    last_name "Norrell"
    sequence(:email) {|n| "jonathan#{n}@norrell.com"}
    password "password"
    employee true
    on_probation false
    created_at { 1.day.ago }
    confirmed_at { 1.day.ago }
    profile_picture_updated_at { Time.now }
  end
end
