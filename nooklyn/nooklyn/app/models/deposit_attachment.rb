class DepositAttachment < ActiveRecord::Base

  belongs_to :deposit

  validates :attachment, attachment_presence: true
  has_attached_file :attachment,
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    path: "deposit_attachments/:id/:filename"

  validates_attachment :attachment, content_type: { content_type: "application/pdf" }
end
