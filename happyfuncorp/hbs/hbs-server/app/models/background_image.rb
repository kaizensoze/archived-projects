# == Schema Information
#
# Table name: background_images
#
#  id         :integer          not null, primary key
#  image      :string(255)      not null
#  active     :boolean          default(TRUE)
#  sort_order :integer
#  created_at :datetime
#  updated_at :datetime
#  

class BackgroundImage < ActiveRecord::Base
  mount_uploader :image, BackgroundImageUploader

  validates :image, presence: true
  validate :check_all_inactive

  before_save :set_sort_order
  after_save :invalidate_cache
  after_destroy :invalidate_cache

  def check_all_inactive
    num_active = BackgroundImage.where(active: true).size
    if !self.active && num_active <= 1
      errors.add(:min_active, 'There must be at least one active background image.')
    end
  end

  def set_sort_order
    if self.sort_order.nil?
      max_sort_order = BackgroundImage.maximum(:sort_order) || 0
      self.sort_order = max_sort_order + 1
    end
  end

  def invalidate_cache
    REDIS.del('background-images')
  end
end
