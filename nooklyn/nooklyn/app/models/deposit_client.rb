class DepositClient < ActiveRecord::Base
  belongs_to :deposit
  validates :name, presence: true, length: { maximum: 250 }
end
