class LocationPhoto < ActiveRecord::Base
  belongs_to :location

  has_attached_file :image,
                    styles: {
                      mega_standard: "5472x3648#",
                      standard: "1920x1080#",
                      half_standard: "990x540#",
                      xlarge: "2484x2170#",
                      large: "1242x1085#",
                      medium: "828x723#",
                      thumb: "414x362#" },
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    s3_protocol: :https,
                    path: "locationphotos/:id/:style/:filename",
                    default_url: ActionController::Base.helpers.asset_path('missing.png')
  validates_attachment :image, presence: true,
    content_type: { content_type: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'] },
    size: { in: 0..10.megabytes }

  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
      "name" => read_attribute(:image_file_name),
      "size" => read_attribute(:image_file_size),
      "url" => image.url(:large),
      "delete_url" => location_photo_path(self),
      "delete_type" => "DELETE"
    }
  end
end
