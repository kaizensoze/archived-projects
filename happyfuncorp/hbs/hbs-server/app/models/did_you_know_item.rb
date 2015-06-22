# == Schema Information
#
# Table name: did_you_know_items
#
#  id                      :integer          not null, primary key
#  title                   :string(255)
#  website                 :string(255)
#  email                   :string(255)
#  phone_number            :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  did_you_know_subject_id :integer
#  sort_order              :integer
#

class DidYouKnowItem < ActiveRecord::Base
  belongs_to :did_you_know_subject

  before_save :set_sort_order
  after_save :invalidate_cache
  after_destroy :invalidate_cache

  def set_sort_order
    if self.sort_order.nil?
      max_sort_order = DidYouKnowItem.where(did_you_know_subject_id: self.did_you_know_subject_id).maximum(:sort_order) || 0
      self.sort_order = max_sort_order + 1
    end
  end

  def invalidate_cache
    REDIS.del('did-you-know')
  end
end
