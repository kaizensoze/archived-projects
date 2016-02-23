class RoomPost < ActiveRecord::Base
  belongs_to :agent
  belongs_to :neighborhood

  validates :price, presence: true
  validates :price, numericality: true

  validates :description, presence: true
  validates :when, presence: true
  validates :neighborhood, presence: true

  validates :latitude, presence: true
  validates :longitude, presence: true

  has_attached_file :image,
                    styles: {
                      large: "640x640#",
                      medium: "320x320#",
                      thumb: "100x100#" },
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    path: "rooms/:id/:style/:filename",
                    s3_protocol: :https,
                    default_url: "/images/:style/missing.png"

  validates :image, attachment_presence: true
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  has_many :likes, class_name: 'RoomPostLike', dependent: :destroy
  has_many :interested_agents, through: :likes, source: :agent

  has_many :rooms, dependent: :destroy

  scope :visible, -> { where(hidden: false) }
  scope :upcoming, -> { where(when: Time.current.beginning_of_day..Time.current.end_of_day + 364.days) }
end
