# == Schema Information
#
# Table name: background_images
#
#  id         :integer          not null, primary key
#  image      :string(255)      not null
#  active     :boolean          default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#  sort_order :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :background_image do
  end
end
