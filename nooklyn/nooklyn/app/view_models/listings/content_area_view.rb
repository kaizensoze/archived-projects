module Listings
  class ContentAreaView

    attr_reader :listing

    def initialize(listing)
      @listing = listing
    end

    def amenities
      listing.amenities.split("\n")
    end

    def application_pending?
      listing.status == 'Application Pending'
    end

    def bed_bath_shorthand
      "#{helpers.number_to_human(bedrooms)} Bed / #{helpers.number_to_human(bathrooms)} Bath"
    end

    def borough_name
      listing.neighborhood.borough
    end

    def phone_contact
      if has_sales_agent?
        sales_agent.phone
      else
        '347.318.3595'
      end
    end

    def description
      listing.description
    end

    def bathrooms
      listing.bathrooms
    end

    def bathroom_message
      "#{helpers.number_to_human(bathrooms)} bathroom(s)"
    end

    def bedrooms
      listing.bedrooms
    end

    def has_sales_agent?
      !listing.sales_agent.on_probation?
    end

    def likes_listing?(agent)
      listing.interested_agents.include?(agent)
    end

    def listed_by
      if has_sales_agent?
        listing.sales_agent.first_name
      else
        'Nooklyn'
      end
    end

    def listing_id
      listing.id
    end

    def main_image
      large_image.presence || listing.thumb
    end

    def nearest_subway_station
      listing.station
    end

    def neighborhood_borough_message
      if in_brooklyn?
        neighborhood_name
      else
        "#{neighborhood_name}, #{borough_name}"
      end
    end

    def neighborhood_name
      listing.neighborhood.name
    end

    def borough_name
      listing.neighborhood.borough
    end

    def number_likes
      listing.likes.count
    end

    def pets_message
      suffix = if listing.pets
                 'are allowed'
               else
                 'are not allowed'
               end

      "Pets #{suffix}"
    end

    def price
      listing.price
    end

    def residential_listing?
      listing.residential?
    end

    def sales_agent
      listing.sales_agent
    end

    def sales_agent_thumbnail
      listing.sales_agent.profile_picture.url(:thumb)
    end

    def square_feet_message(suffix: '')
      if listing.square_feet
        "#{listing.square_feet} square feet#{suffix}"
      else
        ''
      end
    end

    def subway_lines
      listing.subway_line.split
    end

    private

    def helpers
      ActionController::Base.helpers
    end

    def in_brooklyn?
      borough_name == 'Brooklyn'
    end

    def large_image
      @listing.image(:large)
    end
  end
end
