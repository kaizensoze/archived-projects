class Office < ActiveRecord::Base
  has_many :deposits
  has_many :deposit_transactions
end
