class ListingsCollection < ActiveRecord::Base
  include FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :agent
  has_many :listings_collection_memberships
  has_many :listings, through: :listings_collection_memberships

  validates :name, presence: true
  validates :agent, presence: true
  validates_uniqueness_of :slug, case_sensitive: false

  scope :visible, -> { where(private: false) }

  def to_param
    slug
  end

  def slug_candidates
    [
      :name,
      "#{self.name} by #{agent.name}",
      "#{self.name} by #{agent.name} #{(self.created_at || Time.current).strftime("%F")}"
    ]
  end
end
