FactoryGirl.define do
  factory :lead do
    full_name "Mitski Miyawaki"
    phone "543-124-7644"
    max_price 1200
    move_in { Date.today + 2.weeks }
  end
end
