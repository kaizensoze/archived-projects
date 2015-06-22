# == Schema Information
#
# Table name: polls
#
#  id         :integer          not null, primary key
#  active_id  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Poll < ActiveRecord::Base

  after_save :invalidate_cache
  after_destroy :invalidate_cache

  def invalidate_cache
    REDIS.del("polls_#{self.id}")
  end
end
