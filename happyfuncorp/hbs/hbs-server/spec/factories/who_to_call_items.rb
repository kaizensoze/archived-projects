# == Schema Information
#
# Table name: who_to_call_items
#
#  id                     :integer          not null, primary key
#  title                  :string(255)
#  name                   :string(255)
#  phone_number           :string(255)
#  email                  :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  sort_order             :integer
#  who_to_call_subject_id :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :who_to_call_item do
  end
end
