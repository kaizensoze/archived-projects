class Feedback < ActiveRecord::Base
  validates :message, presence: true
end
