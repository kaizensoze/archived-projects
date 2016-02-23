class Lead < ActiveRecord::Base
  belongs_to :agent

  validates :full_name, presence: true
  validates :phone, presence: true
  validates :max_price, presence: true
  validates :move_in, presence: true
  validates :email, length: { maximum: 250 }

  has_many :updates,
           class_name: 'LeadUpdate',
           dependent: :destroy

  has_many :agents, through: :updates


  scope :upcoming, -> { where('leads.move_in >= ? AND leads.move_in <= ?', Time.current.beginning_of_day, Time.current.beginning_of_day + 365.days) }
end
