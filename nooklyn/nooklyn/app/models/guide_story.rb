class GuideStory < ActiveRecord::Base
  belongs_to :guide
  belongs_to :neighborhood
  has_many :photos, class_name: 'GuideStoryPhoto', dependent: :destroy
  has_attached_file :image,
                    :styles => {
                      mega_standard: "5472x3648#",
                      standard: "1920x1080#",
                      xlarge: "2484x2170#",
                      large: "1242x1085#",
                      medium: "828x723#",
                      thumb: "414x362#",
                      :wide_small => "1170x500#",
                      :wide_big => "1920x1080#",
                      :square_big => "500x500#",
                      :square_small => "250x250#" },
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :s3_protocol => :https,
                    :path => "guide_stories/:id/:style/:filename",
                    :default_url => ActionController::Base.helpers.asset_path('missing.png')
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
end
