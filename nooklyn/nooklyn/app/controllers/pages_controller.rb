class PagesController < ApplicationController
  layout "nklyn-pages", only: [:fair_housing, :about, :jobs]

  def home
    @neighborhoods = Neighborhood.visible.order(name: :asc)
    @photos = LocationPhoto.all.limit(24).order("RANDOM()")
  end

  def about
  end

  def contact
  end

  def monitor
    @locations = Location.geo_search(longitude: -73.9420559, latitude: 40.7194209 ).records
  end

  def common_pacific
    @locations = Location.geo_search(longitude: -73.9558957, latitude: 40.677741 ).records
  end
end
