class Location < ActiveRecord::Base
  include Locationable

  belongs_to :neighborhood
  belongs_to :location_category

  has_many :likes, class_name: 'LocationLike', dependent: :destroy
  has_many :interested_agents, through: :likes, source: :agent

  has_many :photos, class_name: 'LocationPhoto', dependent: :destroy

  # General validations
  validates :name, presence: true
  validates :neighborhood_id, presence: true
  validates :location_category_id, presence: true

  # Location validations
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :address_line_one, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true

  scope :by_hood, -> { where(neighborhood_id: 3) }
  scope :modern_layout, -> { where(modern: true) }
  scope :featured, -> { where(featured: true) }

  has_attached_file :image,
                    styles: {
                      xxlarge: "2500x2500#",
                      xlarge: "1250x1250#",
                      large: "612x612#",
                      medium: "250x250#",
                      thumb: "100x100#" },
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    s3_protocol: :https,
                    path: "locations/:id/:style/:filename",
                    default_url: ActionController::Base.helpers.asset_path('missing.png')

  has_attached_file :cover_image,
                    :styles => {
                      :wide_small => "1170x500#",
                      :wide_big => "1920x1080#",
                      xlarge: "2484x2170#",
                      large: "1242x1085#",
                      medium: "828x723#",
                      thumb: "414x362#" },
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :s3_protocol => :https,
                    :path => "locations/cover_images/:id//:style/:filename",
                    :default_url => ActionController::Base.helpers.asset_path('missing.png')

  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :cover_image, :content_type => /\Aimage\/.*\Z/

  def full_address
    "#{address_line_one}\n#{city}, #{state} #{zip}"
  end

  def address
    "#{address_line_one}\n#{city}, #{state} #{zip}"
  end

  def to_param
    "#{id}-#{slug}"
  end

end
