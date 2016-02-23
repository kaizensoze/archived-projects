class CheckRequestDocument < ActiveRecord::Base

  belongs_to :check_request

  validates :attachment, attachment_presence: true
  has_attached_file :attachment,
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    path: "check_request_attachments/:id/:filename"

  validates_attachment :attachment, content_type: { content_type: "application/pdf" }
end
