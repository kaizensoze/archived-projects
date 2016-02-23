class Agent < ActiveRecord::Base

  after_commit :generate_slug
  devise :database_authenticatable, :async, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  include Agentable

  has_many :deposit_stats,
    class_name: 'AgentDepositStat'

  has_many :hearts
  has_many :liked_listings, through: :hearts, source: :listing
  has_many :listing_ignores
  has_many :ignored_listings, through: :listing_ignores, source: :listing

  has_many :sales_agent_listings, foreign_key: "sales_agent_id", class_name: "Listing"
  has_many :listing_agent_listings, foreign_key: "listing_agent_id", class_name: "Listing"

  has_many :mate_posts
  has_many :mate_post_likes
  has_many :liked_mates, through: :mate_post_likes, source: :mate_post
  has_many :mate_post_ignores
  has_many :ignored_mates, through: :mate_post_ignores, source: :mate_post

  has_many :room_posts
  has_many :room_post_likes
  has_many :liked_rooms, through: :room_post_likes, source: :room_post

  has_many :location_likes
  has_many :liked_locations, through: :location_likes, source: :location

  has_many :listings_collections

  has_many :check_requests

  has_many :listing_agent_deposits, foreign_key: "listing_agent_id", class_name: "Deposit"
  has_many :sales_agent_deposits, foreign_key: "sales_agent_id", class_name: "Deposit"
  has_many :split_agent_deposits, foreign_key: "other_sales_agent_id", class_name: "Deposit"
  has_many :training_agent_deposits, foreign_key: "training_agent_id", class_name: "Deposit"

  scope :lastmonth, -> { where('agents.created_at <= ? AND agents.created_at >= ?', Time.current.beginning_of_day, Time.current.end_of_day - 30.days) }
  scope :non_employees, -> { where(:employee => "false") }
  scope :employees, -> { where(:employee => "true") }

  scope :is_super_admin, -> { where(:super_admin => "true") }
  scope :is_not_super_admin, -> { where(:super_admin => "false") }

  scope :probation_employees, -> { where(:on_probation => "true") }
  scope :not_on_probation, -> { where(:on_probation => "false") }
  scope :has_profile_picture, -> { where('agents.profile_picture_updated_at >= ? AND agents.profile_picture_updated_at <= ?', Time.current.beginning_of_year - 1.year, Time.current.end_of_day) }

  has_attached_file :profile_picture,
                    styles: {
                      xlarge: "1000x1000#",
                      large: "500x500#",
                      medium: "250x250#",
                      thumb: "100x100#" },
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    s3_protocol: :https,
                    path: "agents/:id/:style/:filename",
                    default_url: ActionController::Base.helpers.asset_path('missing.png')

  validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/

  def name
    "#{first_name} #{last_name}"
  end

  def short_name
    first_name + " " + last_name[0...1] + "."
  end

  def has_photo?
    !profile_picture.nil?
  end

  def to_param
    slug
  end

  validates :first_name, presence: true
  validates :last_name, presence: true

  def self.find_for_facebook_oauth(auth)
    agent = Agent.where(provider: auth.provider, uid: auth.uid).first
    agent ||= Agent.find_by(email: auth.info.email) if auth.info.email.present?
    if agent
      agent.provider = auth.provider
      agent.uid = auth.uid
      agent.oauth_token = auth.credentials.token
      agent.oauth_expires_at = Time.at(auth.credentials.expires_at)
      agent.image = auth.info.image if agent.image.nil?
      agent.facebook_url = auth.extra.raw_info.link
      agent.gender = auth.extra.raw_info.gender
      agent.save(:validate => false)
      return agent
    else
      where(provider: auth.provider, uid: auth.uid).first_or_create do |agent|
        agent.provider = auth.provider
        agent.uid = auth.uid
        agent.email = auth.info.email
        agent.password = Devise.friendly_token[0,20]
        agent.oauth_token = auth.credentials.token
        agent.oauth_expires_at = Time.at(auth.credentials.expires_at)
        agent.image = auth.info.image
        agent.first_name = auth.extra.raw_info.first_name
        agent.last_name = auth.extra.raw_info.last_name
        agent.facebook_url = auth.extra.raw_info.link
        agent.gender = auth.extra.raw_info.gender
        agent.save(:validate => false)
      end
    end
  end

  private

  def generate_slug
    formatted_firstname = self.first_name.downcase.strip.gsub(/[^a-z0-9\s]/i, '').gsub(/\s/i, '-')
    formatted_lastname = self.last_name.downcase.strip.gsub(/[^a-z0-9\s]/i, '').gsub(/\s/i, '-')
    formatted_agent_id = self.id
    self.slug = "#{formatted_agent_id}-#{formatted_firstname}-#{formatted_lastname}"
  end

end
