class Deposit < ActiveRecord::Base
  belongs_to :listing_agent, class_name: "Agent"
  belongs_to :sales_agent, class_name: "Agent"
  belongs_to :other_sales_agent, class_name: "Agent"
  belongs_to :training_agent, class_name: "Agent"
  belongs_to :deposit_status
  belongs_to :office

  has_many :transactions, class_name: 'DepositTransaction', dependent: :destroy
  has_many :clients, class_name: 'DepositClient', dependent: :destroy
  has_many :documents, class_name: 'DepositAttachment', dependent: :destroy

  validates :address, presence: true, length: { maximum: 250 }
  validates :unit, presence: true, length: { maximum: 250 }
  validates :listing_agent_id, presence: true
  validates :sales_agent_id, presence: true
  validates :apartment_price, presence: true
  validates :when, presence: true
  validates :length_of_lease, presence: true
  validates :deposit_status_id, presence: true
  validates :office_id, presence: true
  validates :credit_check, presence: true

  scope :pending, -> { where(:refund => false ) }
  scope :refunded, -> { where(:refund => true ) }

  scope :bushwick, -> { where(:office_id => 1 ) }
  scope :crown_heights, -> { where(:office_id => 3 ) }
  scope :greenpoint, -> { where(:office_id => 2 ) }

  scope :signed_and_approved, -> { where(:deposit_status_id => [3] ) }
  scope :active_deposits, -> { where(:deposit_status_id => [1,2] ) }
  scope :backed_out, -> { where(:deposit_status_id => 4 ) }


  def self.with_agent(agent)
    if agent.admin?
      Deposit.all
    else
      tbl = Deposit.arel_table
      listing_agent_filter = tbl[:listing_agent_id].eq(agent.id)
      sales_agent_filter = tbl[:sales_agent_id].eq(agent.id)
      other_sales_filter = tbl[:other_sales_agent_id].eq(agent.id)
      training_agent_filter = tbl[:training_agent_id].eq(agent.id)
      chained_filter = listing_agent_filter.or(sales_agent_filter).or(other_sales_filter)

      Deposit.where(chained_filter)
    end
  end

end
