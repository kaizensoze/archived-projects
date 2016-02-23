class Photo < ActiveRecord::Base
  belongs_to :listing

  has_attached_file :image,
  		styles: {
  			thumb: "250x250#",
        large: "1250x1250#",
  			square: "612x612#" },
  		storage: :s3,
  		s3_credentials: "#{Rails.root}/config/s3.yml",
      s3_protocol: :https,
  		path: "/:style/:id/:filename"

  scope :special, -> { where(:featured => true) }
  validates_attachment :image, presence: true,
    content_type: { content_type: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'] },
    size: { in: 0..10.megabytes }

  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
      "name" => read_attribute(:image_file_name),
      "size" => read_attribute(:image_file_size),
      "url" => image.url(:square),
      "delete_url" => photo_path(self),
      "delete_type" => "DELETE"
    }
  end
end
