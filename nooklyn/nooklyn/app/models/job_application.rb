class JobApplication < ActiveRecord::Base
  validates :full_name, presence: true, length: { maximum: 250 }
  validates :email, presence: true, length: { maximum: 250 }
  validates :phone, presence: true, length: { maximum: 250 }
  validates :current_company, presence: true, length: { maximum: 250 }

  belongs_to :agent

  validates :resume, attachment_presence: true
  has_attached_file :resume,
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    path: "applications/:id/:filename"

  validates_attachment :resume, content_type: { content_type: "application/pdf" }

  POSITIONS = [
    'Licensed Real Estate Rentals Agent, Brooklyn',
    'Licensed Real Estate Rentals Agent, Manhattan',
    'Licensed Real Estate Sales Agent, Brooklyn',
    'Licensed Real Estate Sales Agent, Manhattan',
    'Commercial Leasing Agent, Brooklyn',
    'Commercial Leasing Agent, Manhattan',
    'Full Time Office Manager, Manhattan',
    'iOS Engineer',
    'Marketing Manager'
    ]

  validates :position,
    presence: true,
    inclusion: {
      in: POSITIONS,
      message: 'must selected from the available choices'
    }

  def self.positions
    POSITIONS
  end

end
