class Heart < ActiveRecord::Base
  belongs_to :agent
  belongs_to :listing, :counter_cache => true

  validates :agent_id, :uniqueness => {:scope => :listing_id}
end
