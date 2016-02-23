class Matrix::StatisticsController < ApplicationController

  def daily_active_mate_profiles
    respond_to do |format|
      format.csv { send_data DailyActiveMateProfile.to_csv }
    end
  end
end
