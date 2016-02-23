module Listings
  class ShowView

    DEFAULT_KEYWORDS = %w[brooklyn rentals sales lofts apartments real\ estate]

    DEFAULT_IMAGES = [
      'https://nooklyn-files.s3.amazonaws.com/listing/nooklyn-seal.png',
      'https://nooklyn-files.s3.amazonaws.com/listing/office-square.jpg',
      'https://nooklyn-files.s3.amazonaws.com/listing/powered.png'
    ]

    attr_reader :listing

    delegate :latitude, :longitude, :price, to: :listing

    def initialize(listing)
      @listing = listing
    end

    def content_area_view
      ContentAreaView.new(listing)
    end

    def description
      "#{@listing.title.humanize} #{@listing.description.humanize}"
    end

    def has_photos?
      !photos.empty?
    end

    def images
      @_images ||= DEFAULT_IMAGES.zip(square_photo_urls)
        .flat_map { |tuple| tuple.compact.last }
        .unshift(large_image)
    end

    def keywords
      amenities = @listing.amenities
        .split("\n")
        .map(&:squish)
      (DEFAULT_KEYWORDS + amenities).join(', ')
    end

    def listing_type
      if listing.bedrooms == 0
        'loft'
      elsif !listing.residential
        'commerical property'
      else
        'apartment'
      end
    end

    def locations
      Location.geo_search(longitude: longitude, latitude: latitude)
        .records
        .includes(:location_category)
    end

    def main_image
      large_image
    end

    def neighborhood_name
      listing.neighborhood.name
    end

    def photos
      listing.photos.order(featured: :desc)
    end

    def rented?
      @listing.status == 'Rented'
    end

    private

    def large_image
      @listing.image(:large)
    end

    def square_photo_urls
      photos.map { |p| p.image.url(:square) }
    end
  end
end
