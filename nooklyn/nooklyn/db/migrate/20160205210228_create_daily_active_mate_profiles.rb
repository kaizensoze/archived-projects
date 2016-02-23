class CreateDailyActiveMateProfiles < ActiveRecord::Migration
  def change
    create_view :daily_active_mate_profiles
  end
end
