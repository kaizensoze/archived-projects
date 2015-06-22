# == Schema Information
#
# Table name: help_now_items
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  body         :string(255)
#  phone_number :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  sort_order   :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :help_now_item do
  end
end
