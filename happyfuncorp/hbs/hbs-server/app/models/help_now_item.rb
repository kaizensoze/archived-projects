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

class HelpNowItem < ActiveRecord::Base

  before_save :set_sort_order
  after_save :invalidate_cache
  after_destroy :invalidate_cache

  def set_sort_order
    if self.sort_order.nil?
      max_sort_order = HelpNowItem.maximum(:sort_order) || 0
      self.sort_order = max_sort_order + 1
    end
  end

  def invalidate_cache
    REDIS.del('help-now')
  end
end
