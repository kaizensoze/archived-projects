class ListingStatusChange < ActiveRecord::Base
  belongs_to :listing
  belongs_to :agent

  enum status: [:available, :pending, :rented]

  validates :listing_id,
    presence: true

  validates :agent_id,
    presence: true

  validates :status,
    presence: true

  def humanable_status
    if available?
      'Available'
    elsif pending?
      'Application Pending'
    elsif rented?
      'Rented'
    end
  end
end
