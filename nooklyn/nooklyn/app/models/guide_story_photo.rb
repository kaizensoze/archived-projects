class GuideStoryPhoto < ActiveRecord::Base
  belongs_to :guide_story

  has_attached_file :image,
                    styles: {
                      mega_standard: "5472x3648#",
                      standard: "1920x1080#",
                      xlarge: "2484x2170#",
                      large: "1242x1085#",
                      medium: "828x723#",
                      thumb: "414x362#" },
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    s3_protocol: :https,
                    path: "guide_story_photos/:id/:style/:filename",
                    default_url: ActionController::Base.helpers.asset_path('missing.png')
  validates_attachment :image, presence: true,
    content_type: { content_type: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'] },
    size: { in: 0..10.megabytes }

  include Rails.application.routes.url_helpers

  validates :caption, length: { maximum: 250 }

  def to_jq_upload
    {
      "name" => read_attribute(:image_file_name),
      "size" => read_attribute(:image_file_size),
      "url" => image.url(:large),
      "delete_url" => guide_story_photo_path(self),
      "delete_type" => "DELETE"
    }
  end
end
