# == Schema Information
#
# Table name: menus
#
#  id            :integer          not null, primary key
#  date          :date             not null
#  summary       :string(255)      not null
#  body          :text             not null
#  admin_user_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Menu < ActiveRecord::Base
  belongs_to :admin_user
  validates :date, uniqueness: { message: 'A menu already exists with this date. Please try a different date.' }
end
