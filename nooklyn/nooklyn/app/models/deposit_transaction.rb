class DepositTransaction < ActiveRecord::Base
  belongs_to :deposit
  belongs_to :office

  TYPES = [
    'Cash',
    'Chase QuickPay',
    'Bank Check',
    'Money Order',
    'Paypal',
    'Credit Card',
    'Personal Check'
  ]

  validates :amount, presence: true
  validates :deposit_transaction_type,
    presence: true,
    inclusion: {
      in: TYPES,
      message: 'must selected from the available choices'
    }

  def self.types
    TYPES
  end
end
