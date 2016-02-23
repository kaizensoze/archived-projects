class DepositStatus < ActiveRecord::Base
  has_many :deposits
  validates :name, presence: true
  validates :description, presence: true
end
