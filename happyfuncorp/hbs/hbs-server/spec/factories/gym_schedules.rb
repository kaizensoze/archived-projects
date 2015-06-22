# == Schema Information
#
# Table name: gym_schedules
#
#  id            :integer          not null, primary key
#  date          :date             not null
#  summary       :string(255)      not null
#  body          :text             not null
#  admin_user_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gym_schedule do
    date "2014-08-06"
    summary "MyText"
  end
end
