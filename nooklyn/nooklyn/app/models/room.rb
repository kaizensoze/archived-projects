class Room < ActiveRecord::Base
  belongs_to :room_post
  belongs_to :room_category

  has_attached_file :picture,
                    styles: {
                      medium: "320x320#",
                      thumb: "100x100#" },
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    s3_protocol: :https,
                    path: "room/:id/:style/:filename",
                    default_url: "/images/:style/missing.png"

  validates :picture, attachment_presence: true
  validates :room_category, presence: true
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
end
