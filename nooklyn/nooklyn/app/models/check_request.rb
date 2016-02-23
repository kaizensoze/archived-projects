class CheckRequest < ActiveRecord::Base
  belongs_to :agent
  belongs_to :check_request_type

  has_many :documents,
           :class_name => "CheckRequestDocument",
           :dependent => :destroy

  validates :name, presence: true
  validates :apartment_address, presence: true
  validates :unit, presence: true
  validates :amount, presence: true
  validates :amount, numericality: { greater_than: 1 }
  validates :agent_id, presence: true
  validates :check_date, presence: true

  scope :already_approved, -> { where(:approved => true) }
  scope :pending_approval, -> { where(:approved => false) }

  scope :already_verified, -> { where(:verified => true) }

  scope :already_rejected, -> { where(:rejected => true) }
  scope :pending_rejection, -> { where(:rejected => false) }

  def self.with_agent(agent)
    agent.admin? ? where({}) : where(:agent_id => agent.id)
  end
end
