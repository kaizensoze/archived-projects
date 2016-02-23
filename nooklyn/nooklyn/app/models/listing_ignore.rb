class ListingIgnore < ActiveRecord::Base
  belongs_to :agent
  belongs_to :listing

  validates :agent_id, :uniqueness => {:scope => :listing_id}
end
