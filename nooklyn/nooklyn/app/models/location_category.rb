class LocationCategory < ActiveRecord::Base
  has_many :locations

  has_attached_file :image,
                    :styles => {
                      :large => "416x374#",
                      :thumb => "208x187#" },
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :s3_protocol => :https,
                    :path => "location_categories/:id/:style/:filename",
                    :default_url => ActionController::Base.helpers.asset_path('missing.png')

  validates :name, presence: true
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  scope :visible, -> { where(:featured => true) }

  def to_param
    slug
  end

end
