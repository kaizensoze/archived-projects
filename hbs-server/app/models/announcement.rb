# == Schema Information
#
# Table name: announcements
#
#  id            :integer          not null, primary key
#  summary       :string(255)      not null
#  headline      :string(255)      not null
#  image         :string(255)
#  body          :text             not null
#  location      :string(255)
#  start_time    :datetime
#  end_time      :datetime
#  has_button    :boolean
#  button_text   :string(255)
#  button_link   :string(255)
#  active        :boolean          default(TRUE)
#  sort_order    :integer
#  admin_user_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Announcement < ActiveRecord::Base
  belongs_to :admin_user

  mount_uploader :image, AnnouncementImageUploader

  validates :summary, presence: true
  validates :headline, presence: true
  validates :body, presence: true

  before_save :set_sort_order
  after_save :invalidate_cache
  after_destroy :invalidate_cache

  def set_sort_order
    if self.sort_order.nil?
      max_sort_order = Announcement.maximum(:sort_order) || 0
      self.sort_order = max_sort_order + 1
    end
  end

  def invalidate_cache
    REDIS.del('announcements')
  end
end
