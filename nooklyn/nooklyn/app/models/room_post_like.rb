class RoomPostLike < ActiveRecord::Base
  belongs_to :agent
  belongs_to :room_post

  validates :agent_id, uniqueness: { scope: :room_post }
end
