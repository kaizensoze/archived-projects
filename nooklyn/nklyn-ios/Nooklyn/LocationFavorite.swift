//
//  LocationFavorite.swift
//  Nooklyn
//
//  Created by Joe Gallo on 11/9/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

class LocationFavorite: Location {
    
    override init() {
        super.init()
    }
    
    override init(dict: NSDictionary) {
        super.init(dict: dict)
    }
    
    override init(dict2: NSDictionary) {
        super.init(dict2: dict2)
    }
    
    init(location: Location) {
        super.init()
        copyFromLocation(location)
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
        let copy = super.copyWithZone(zone) as! LocationFavorite
        return copy
    }
    
    // MARK: - Copy from location
    
    private func copyFromLocation(location: Location) {
        id = location.id
        name = location.name
        imageURL = location.imageURL
        mediumImageURL = location.mediumImageURL
        thumbnailURL = location.thumbnailURL
        latitude = location.latitude
        longitude = location.longitude
        address = location.address
        _description = location._description
        photosURL = location.photosURL
        categoryId = location.categoryId
        category = location.category
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? LocationFavorite {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: LocationFavorite, rhs: LocationFavorite) -> Bool {
    return lhs.id == rhs.id
}
