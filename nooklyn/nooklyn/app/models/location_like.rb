class LocationLike < ActiveRecord::Base
  belongs_to :agent
  belongs_to :location

  validates :agent_id, :uniqueness => {:scope => :location}
end
