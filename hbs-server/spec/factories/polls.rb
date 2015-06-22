# == Schema Information
#
# Table name: polls
#
#  id         :integer          not null, primary key
#  active_id  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :poll do
  end
end
