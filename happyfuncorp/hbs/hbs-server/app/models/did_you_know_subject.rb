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

class DidYouKnowSubject < ActiveRecord::Base
  has_many :did_you_know_items, dependent: :destroy

  before_save :set_sort_order
  after_save :invalidate_cache
  after_destroy :invalidate_cache

  def set_sort_order
    if self.sort_order.nil?
      max_sort_order = DidYouKnowSubject.maximum(:sort_order) || 0
      self.sort_order = max_sort_order + 1
    end
  end

  def invalidate_cache
    REDIS.del('did-you-know')
  end
end
