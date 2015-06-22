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

require 'rails_helper'

RSpec.describe GymSchedule, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
