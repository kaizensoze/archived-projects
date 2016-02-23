class DailyActiveMateProfile < ActiveRecord::Base
  self.primary_key = :id
  default_scope { order(:id) }

  scope :ytd, -> { where(date: (Date.current - 1.year)..Date.current) }

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |daily_stat|
        csv << daily_stat.attributes.values_at(*column_names)
      end
    end

  end

  private

  def readonly?
    true
  end
end
