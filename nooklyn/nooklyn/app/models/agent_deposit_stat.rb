class AgentDepositStat < ActiveRecord::Base
  belongs_to :agent

  scope :ranked, -> { order(:monthly_rank) }

  def self.current_month
    now = Time.zone.now
    where(year: now.year, month: now.month)
  end

  private

  def readonly?
    true
  end
end
