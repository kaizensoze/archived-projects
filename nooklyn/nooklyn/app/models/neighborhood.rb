class Neighborhood < ActiveRecord::Base
  has_many :listings
  has_many :locations
  has_many :room_posts
  has_many :mate_posts
  has_many :location_categories, -> { uniq }, through: :locations
  has_many :photos, through: :locations
  has_one :guide

  belongs_to :region

  validates :name, presence: true
  validates :region_id, presence: true
  validates :slug, uniqueness: true

  has_attached_file :image,
                    styles: {
                      xlarge: "2484x2170#",
                      large: "1242x1085#",
                      medium: "828x723#",
                      thumb: "414x362#" },
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    s3_protocol: :https,
                    path: "neighborhoods/:id/:style/:filename",
                    default_url: ActionController::Base.helpers.asset_path('missing.png')

  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  scope :ordered_name, -> { order(name: :asc) }
  scope :visible, -> { where(featured: true) }
  scope :non_featured, -> { where(featured: false) }

  scope :brooklyn, -> { where(region_id: 1) }
  scope :queens, -> { where(region_id: 3) }
  scope :brooklyn_and_queens, -> { where(region_id: [1, 3] ) }
  scope :nyc, -> { where(region_id: [1, 2, 3] ) }

  def full_name
  	name + ", " + borough + ", NY"
  end

  def to_param
    slug
  end
end
