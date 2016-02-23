FactoryGirl.define do
  factory :neighborhood do
    sequence(:name) {|n| "#{n}th Williamsburg" }
    region_id 1
    sequence(:slug) {|n| "william#{n}burg" }
    featured true
    borough "Brooklyn"

    trait :with_listing do
      after :create do |instance|
        create(:listing, neighborhood: instance)
      end
    end
  end
end
