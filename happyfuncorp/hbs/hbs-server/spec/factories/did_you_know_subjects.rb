# == Schema Information
#
# Table name: did_you_know_subjects
#
#  id         :integer          not null, primary key
#  subject    :string(255)      not null
#  sort_order :integer
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :did_you_know_subject do
  end
end
