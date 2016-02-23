class MatePost < ActiveRecord::Base
  belongs_to :agent
  belongs_to :neighborhood

  validates :price, presence: true
  validates :neighborhood, presence: true
  validates :price, numericality: true

  validates :description, presence: true
  validates :when, presence: true

  validates :agent_id, uniqueness: { message: ": You can't post more than once." }

  has_attached_file :image,
                    styles: {
                      xlarge: "1280x1280#",
                      large: "640x640#",
                      medium: "320x320#",
                      thumb: "100x100#" },
                    storage: :s3,
                    s3_credentials: "#{Rails.root}/config/s3.yml",
                    s3_protocol: :https,
                    path: "mates/:id/:style/:filename",
                    default_url: "/images/:style/missing.png"

  validates :image, attachment_presence: true
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  has_many :likes, class_name: 'MatePostLike', dependent: :destroy
  has_many :interested_agents, through: :likes, source: :agent

  has_many :views,
    class_name: 'MatePostView',
    dependent: :destroy

  scope :visible, -> { where(:hidden => false) }
  scope :upcoming, -> { where(when: Time.current.beginning_of_day..Time.current.end_of_day + 364.days) }
  scope :recently_expired, -> { where(when: (Date.current - 1.day)..Date.current) }

  def days_until_move_in
    (move_in - Date.current).to_i
  end

  def expired?
    days_until_move_in < 0
  end

  def expires_soon?
    days_until_move_in <= 3
  end

  private

  def move_in
    self.when.to_date
  end
end
