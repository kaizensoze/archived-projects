//
//  Neighborhood.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/2/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

class Neighborhood: NSObject, NSCoding, NSCopying {
    var id = ""
    var name = ""
    var imageURL = ""
    var featured = false
    var latitude = 0.0
    var longitude = 0.0
    var activeListingCount = 0
    var locationCategoryCount = 0
    var regionId = ""
    var region: Region!
    var locations = [Location]()
    
    override init() {
        super.init()
    }
    
    init(dict: NSDictionary) {
        if let id = dict["id"] as? String { self.id = id }
        
        if let attributes = dict["attributes"] as? NSDictionary {
            if let name = attributes["name"] as? String { self.name = name }
            if let imageURL = attributes["image"] as? String { self.imageURL = imageURL }
            if let featured = attributes["featured"] as? Bool { self.featured = featured }
            if let latitude = attributes["latitude"] as? Double { self.latitude = latitude }
            if let longitude = attributes["longitude"] as? Double { self.longitude = longitude }
            if let activeListingCount = attributes["active-listing-count"] as? Int { self.activeListingCount = activeListingCount }
            if let locationCategoryCount = attributes["location-category-count"] as? Int { self.locationCategoryCount = locationCategoryCount }
        }
        
        if let relationships = dict["relationships"] as? NSDictionary {
            // region
            if let regionDict = relationships["region"] as? NSDictionary {
                if let regionData = regionDict["data"] as? NSDictionary {
                    if let regionId = regionData["id"] as? String {
                        self.regionId = regionId
                    }
                }
            }
        }
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        if let id = decoder.decodeObjectForKey("id") as? String { self.id = id }
        if let name = decoder.decodeObjectForKey("name") as? String { self.name = name }
        if let imageURL = decoder.decodeObjectForKey("imageURL") as? String { self.imageURL = imageURL }
        self.featured = decoder.decodeBoolForKey("featured")
        self.latitude = decoder.decodeDoubleForKey("latitude")
        self.longitude = decoder.decodeDoubleForKey("longitude")
        self.activeListingCount = decoder.decodeIntegerForKey("activeListingCount")
        self.locationCategoryCount = decoder.decodeIntegerForKey("locationCategoryCount")
        if let regionId = decoder.decodeObjectForKey("regionId") as? String { self.regionId = regionId }
        if let region = decoder.decodeObjectForKey("region") as? Region { self.region = region }
        if let locations = decoder.decodeObjectForKey("locations") as? [Location] { self.locations = locations }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.imageURL, forKey: "imageURL")
        coder.encodeBool(self.featured, forKey: "featured")
        coder.encodeDouble(self.latitude, forKey: "latitude")
        coder.encodeDouble(self.longitude, forKey: "longitude")
        coder.encodeInt(Int32(self.activeListingCount), forKey: "activeListingCount")
        coder.encodeInt(Int32(self.locationCategoryCount), forKey: "locationCategoryCount")
        coder.encodeObject(self.regionId, forKey: "regionId")
        coder.encodeObject(self.region, forKey: "region")
        coder.encodeObject(self.locations, forKey: "locations")
    }
    
    // MARK: - NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Neighborhood()
        copy.id = id
        copy.name = name
        copy.imageURL = imageURL
        copy.featured = featured
        copy.latitude = latitude
        copy.longitude = longitude
        copy.activeListingCount = activeListingCount
        copy.locationCategoryCount = locationCategoryCount
        copy.regionId = regionId
        copy.region = region
        copy.locations = locations
        return copy
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? Neighborhood {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: Neighborhood, rhs: Neighborhood) -> Bool {
    return lhs.id == rhs.id
}
