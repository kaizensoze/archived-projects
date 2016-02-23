class Region < ActiveRecord::Base
  has_many :neighborhoods, -> { ordered_name }
  has_many :locations, :through => :neighborhoods
  has_many :listings, :through => :neighborhoods

  validates :name, presence: true

  has_attached_file :image,
                    styles: {
                      xlarge: "2484x2170#",
                      large: "1242x1085#",
                      medium: "828x723#",
                      thumb: "414x362#" },
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    s3_protocol: :https,
                    path: "regions/:id/:style/:filename",
                    default_url: ActionController::Base.helpers.asset_path('missing.png')

  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
end
