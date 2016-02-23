//
//  ListingIgnore.swift
//  Nooklyn
//
//  Created by Joe Gallo on 11/5/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

class ListingIgnore: Listing {
    
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
        let copy = super.copyWithZone(zone) as! ListingIgnore
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
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? ListingIgnore {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: ListingIgnore, rhs: ListingIgnore) -> Bool {
    return lhs.id == rhs.id
}
