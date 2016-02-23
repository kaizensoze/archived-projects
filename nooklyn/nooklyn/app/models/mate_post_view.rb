class MatePostView < ActiveRecord::Base
  belongs_to :agent
  belongs_to :mate_post

  enum format: [:card, :post]
end
