//
//  ListingFavorite.swift
//  Nooklyn
//
//  Created by Joe Gallo on 10/10/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

class ListingFavorite: Listing {
    
    override init() {
        super.init()
    }
    
    override init(dict: NSDictionary) {
        super.init(dict: dict)
    }
    
    override init(dict2: NSDictionary) {
        super.init(dict2: dict2)
    }
    
    init(listing: Listing) {
        super.init()
        copyFromListing(listing)
        configure()
    }
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
    }
    
    // MARK: - NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! ListingFavorite
        return copy
    }
    
    // MARK: - Copy from listing
    
    private func copyFromListing(listing: Listing) {
        id = listing.id
        bedrooms = listing.bedrooms
        bathrooms = listing.bathrooms
        price = listing.price
        imageURL = listing.imageURL
        mediumImageURL = listing.mediumImageURL
        thumbnailURL = listing.thumbnailURL
        status = listing.status
        statusVal = listing.statusVal
        _private = listing._private
        featured = listing.featured
        heartsCount = listing.heartsCount
        latitude = listing.latitude
        longitude = listing.longitude
        residential = listing.residential
        rental = listing.rental
        listingDescription = listing.listingDescription
        amenities = listing.amenities
        subwayLines = listing.subwayLines
        subwayStations = listing.subwayStations
        address = listing.address
        apartment = listing.apartment
        access = listing.access
        listingAgentName = listing.listingAgentName
        term = listing.term
        dateAvailable = listing.dateAvailable
        photosURL = listing.photosURL
        neighborhoodId = listing.neighborhoodId
        neighborhood = listing.neighborhood
        agentId = listing.agentId
        agent = listing.agent
    }
    
    // MARK: - Configure
    
    override func configure() {
        self.photosURL = self.photosURL.stringByReplacingOccurrencesOfString("favorites", withString:"listings")
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? ListingFavorite {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: ListingFavorite, rhs: ListingFavorite) -> Bool {
    return lhs.id == rhs.id
}
