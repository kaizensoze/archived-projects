class Listing < ActiveRecord::Base
  include Listingable

  has_many :photos
  belongs_to :listing_agent, class_name: "Agent"
  belongs_to :sales_agent, class_name: "Agent"
  belongs_to :neighborhood
  belongs_to :office
  has_many :likes, class_name: 'Heart', dependent: :destroy
  has_many :interested_agents, through: :likes, source: :agent
  has_many :status_changes,
    -> { includes(:agent).order(created_at: :desc).readonly },
    class_name: 'ListingStatusChange'

  has_attached_file :image,
                    styles: {
                      xxlarge: "2500x2500#",
                      xlarge: "1250x1250#",
                      large: "750x750#",
                      medium: "500x500#",
                      thumb: "250x250#",
                      xsthumb: "125x125#"
                       },
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    s3_protocol: :https,
                    path: "listings/:id/:style/:filename",
                    default_url: ActionController::Base.helpers.asset_path('missing.png')


  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  validates :title, presence: true, length: { maximum: 250 }
  validates :address, presence: true, length: { maximum: 250 }
  validates :latitude, presence: { message: "Pin location is required" }
  validates :longitude, presence: { message: "Pin location is required" }
  validates :description, presence: true
  validates :amenities, presence: true
  validates :bathrooms, presence: true
  validates :bedrooms, presence: true
  validates :residential, inclusion: { in: [true, false], message: "Must specify residential or commercial" }
  validates :rental, inclusion: { in: [true, false], message: "Must specify lease or sale" }
  validates :exclusive, inclusion: { in: [true, false], message: "cannot be blank" }
  validates :neighborhood_id, presence: true
  validates :pets, inclusion: { in: [true, false], message: "cannot be blank" }
  validates :price, presence: true
  validates :utilities, presence: true, on: :create
  validates :sales_agent_id, presence: true, on: :create
  validates :listing_agent_id, presence: true, on: :create
  validates :term, length: { maximum: 250 }
  validates :landlord_contact, length: { maximum: 250 }
  validates :fee, length: { maximum: 250 }
  validates :subway_line, length: { maximum: 250 }
  validates :station, length: { maximum: 250 }
  validates :landlord_llc, length: { maximum: 250 }
  validates :apartment, length: { maximum: 250 }

  scope :available, -> { where(:status => "Available" ) }
  scope :pending, -> { where(:status => "Application Pending" ) }
  scope :rented, -> { where(:status => "Rented" ) }
  scope :available_and_pending, -> { where(:status => ["Available", "Application Pending"] ) }

  scope :rentals, -> { where(:rental => true) }
  scope :sales, -> { where(:rental => false) }
  scope :residential, -> { where(:residential => true) }
  scope :commercial, -> { where(:residential => false) }
  scope :visible, -> { where(:private => false) }
  scope :special, -> { where(:featured => true) }
  scope :exclusive, -> { where(:exclusive => true) }
  scope :has_thumbnail, -> { where('listings.image_updated_at >= ? AND listings.image_updated_at <= ?', Time.current.beginning_of_year - 1.year, Time.current.end_of_day) }

  scope :studios, -> { where(bedrooms: 0) }
  scope :one_beds, -> { where(bedrooms: 1) }
  scope :two_beds, -> { where(bedrooms: 2) }
  scope :three_beds, -> { where(bedrooms: 3) }
  scope :four_beds, -> { where(bedrooms: 4) }
  scope :five_beds, -> { where(bedrooms: 5) }

  scope :cheap_apartments, -> { where('listing.price >= ? AND listings.price <= ?', 1000, 2000) }
  scope :mid_apartments, -> { where('listing.price >= ? AND listings.price <= ?', 2000, 3000) }
  scope :expensive_apartments, -> { where('listing.price >= ? AND listings.price <= ?', 3000, 4000) }
  scope :really_expensive_apartments, -> { where('listing.price >= ? AND listings.price <= ?', 4000, 9000) }

  def action_status
    case status
    when "Available"
      "available"
    when "Application Pending"
      "pending"
    when "Rented"
      "rented"
    end
  end

  def thumb
    primaryphoto.gsub("/square/", "/thumb/")
  end

  def primary_thumbnail
    image.url(:medium)
  end

  def pets_value
    if pets?
      " are "
    else
      " are not "
    end
  end

  def cost_per_bed
    if bedrooms == 0
      price
    else
       price / bedrooms
    end
  end

  def cost_per_foot
    if square_feet == 0
      price
    elsif square_feet ==  nil
      "0"
    else
       (price*12) / square_feet.to_i
    end
  end

  def searchable_description
    address + bedrooms.to_i.to_s + " bedrooms" + " / " + bathrooms.to_i.to_s + " bathrooms in " + neighborhood.name + ". Pets" + pets_value + "allowed. " + description
  end

  def subway_line_url
    "https://nooklyn-files.s3.amazonaws.com/subway/2x/<SUBWAY_LINE>.png"
  end

end
