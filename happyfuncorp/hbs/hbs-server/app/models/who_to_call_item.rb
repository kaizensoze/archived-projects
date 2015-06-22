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

class WhoToCallItem < ActiveRecord::Base
  belongs_to :who_to_call_subject

  before_save :set_sort_order
  after_save :invalidate_cache
  after_destroy :invalidate_cache

  def set_sort_order
    if self.sort_order.nil?
      max_sort_order = WhoToCallItem.where(who_to_call_subject_id: self.who_to_call_subject_id).maximum(:sort_order) || 0
      self.sort_order = max_sort_order + 1
    end
  end

  def invalidate_cache
    REDIS.del('who-to-call')
  end
end
