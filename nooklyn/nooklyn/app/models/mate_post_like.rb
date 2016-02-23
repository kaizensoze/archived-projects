class MatePostLike < ActiveRecord::Base
  belongs_to :agent
  belongs_to :mate_post

  validates :agent_id, :uniqueness => {:scope => :mate_post}
end
