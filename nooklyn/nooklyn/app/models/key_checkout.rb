class KeyCheckout < ActiveRecord::Base
  belongs_to :agent
  belongs_to :office

  validates :message, presence: true
  validates :office_id, presence: true
  validates :agent_id, presence: true
end
