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

class GymSchedule < ActiveRecord::Base
  belongs_to :admin_user
  validates :date, uniqueness: { message: 'A gym schedule already exists with this date. Please try a different date.' }
end
