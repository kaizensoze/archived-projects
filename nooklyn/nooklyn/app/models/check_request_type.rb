class CheckRequestType < ActiveRecord::Base
  has_many :check_requests
  scope :usable_types, -> { where(:active => true) }

end
