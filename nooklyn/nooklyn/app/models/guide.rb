class Guide < ActiveRecord::Base
  belongs_to :neighborhood
  has_many :guide_stories

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
                    :path => "guide_stories/:id/:style/:filename",
                    :default_url => ActionController::Base.helpers.asset_path('missing.png')

  validates_attachment_content_type :cover_image, :content_type => /\Aimage\/.*\Z/

  scope :visible, -> { where(:featured => true) }

  def neighborhood_name
    neighborhood.name
  end

  def to_param
    slug
  end
end
