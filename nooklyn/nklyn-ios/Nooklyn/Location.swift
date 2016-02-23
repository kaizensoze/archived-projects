//
//  Location.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/2/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

class Location: NSObject, NSCoding, NSCopying {
    var id = ""
    var name = ""
    var imageURL = ""
    var mediumImageURL = ""
    var thumbnailURL = ""
    var latitude = 0.0
    var longitude = 0.0
    var address = ""
    var _description = ""
    var photosURL = ""
    var categoryId = ""
    var category: LocationCategory?
    
    override init() {
        super.init()
    }
    
    init(dict: NSDictionary) {
        if let id = dict["id"] as? String { self.id = id }

        if let attributes = dict["attributes"] as? NSDictionary {
            if let name = attributes["name"] as? String { self.name = name }
            if let imageURL = attributes["image"] as? String { self.imageURL = imageURL }
            if let mediumImageURL = attributes["medium-image"] as? String { self.mediumImageURL = mediumImageURL }
            if let thumbnailURL = attributes["thumbnail"] as? String { self.thumbnailURL = thumbnailURL }
            if let latitude = attributes["latitude"] as? Double { self.latitude = latitude }
            if let longitude = attributes["longitude"] as? Double { self.longitude = longitude }
            if let address = attributes["address"] as? String { self.address = address }
            if let description = attributes["description"] as? String { self._description = description }
        }
        
        if let relationships = dict["relationships"] as? NSDictionary {
            // photos
            if let photos = relationships["photos"] as? NSDictionary {
                if let links = photos["links"] as? NSDictionary {
                    if let photosURL = links["related"] as? String { self.photosURL = photosURL }
                }
            }
            
            // category
            if let categoryDict = relationships["location-category"] as? NSDictionary {
                if let categoryData = categoryDict["data"] as? NSDictionary {
                    if let categoryId = categoryData["id"] as? String {
                        self.categoryId = categoryId
                    }
                }
            }
        }
    }
    
    // /locations.json
    init(dict2: NSDictionary) {
        if let id = dict2["id"] as? Int { self.id = String(id) }
        if let name = dict2["name"] as? String { self.name = name }
        if let imageURL = dict2["photo_url"] as? String { self.imageURL = imageURL }
        if let mediumImageURL = dict2["medium_photo_url"] as? String { self.mediumImageURL = mediumImageURL }
        if let thumbnailURL = dict2["thumbnail_url"] as? String { self.thumbnailURL = thumbnailURL }
        if let latitude = dict2["latitude"] as? Double { self.latitude = latitude }
        if let longitude = dict2["longitude"] as? Double { self.longitude = longitude }
        if let address = dict2["address"] as? String { self.address = address }
        if let description = dict2["description"] as? String { self._description = description }
        
        self.photosURL = "\(SITE_DOMAIN)\(API_PREFIX)locations/\(id)/photos"
        
        if let locationCategoryDict = dict2["location_category"] as? NSDictionary {
            let locationCategory = LocationCategory(dict2: locationCategoryDict)
            self.categoryId = locationCategory.id
            self.category = locationCategory
        }
    }
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        if let id = decoder.decodeObjectForKey("id") as? String { self.id = id }
        if let name = decoder.decodeObjectForKey("name") as? String { self.name = name }
        if let imageURL = decoder.decodeObjectForKey("imageURL") as? String { self.imageURL = imageURL }
        if let mediumImageURL = decoder.decodeObjectForKey("mediumImageURL") as? String { self.mediumImageURL = mediumImageURL }
        if let thumbnailURL = decoder.decodeObjectForKey("thumbnailURL") as? String { self.thumbnailURL = thumbnailURL }
        self.latitude = decoder.decodeDoubleForKey("latitude")
        self.longitude = decoder.decodeDoubleForKey("longitude")
        if let address = decoder.decodeObjectForKey("address") as? String { self.address = address }
        if let _description = decoder.decodeObjectForKey("_description") as? String { self._description = _description }
        if let photosURL = decoder.decodeObjectForKey("photosURL") as? String { self.photosURL = photosURL }
        if let categoryId = decoder.decodeObjectForKey("categoryId") as? String { self.categoryId = categoryId }
        if let category = decoder.decodeObjectForKey("category") as? LocationCategory { self.category = category }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.imageURL, forKey: "imageURL")
        coder.encodeObject(self.mediumImageURL, forKey: "mediumImageURL")
        coder.encodeObject(self.thumbnailURL, forKey: "thumbnailURL")
        coder.encodeDouble(self.latitude, forKey: "latitude")
        coder.encodeDouble(self.longitude, forKey: "longitude")
        coder.encodeObject(self.address, forKey: "address")
        coder.encodeObject(self._description, forKey: "_description")
        coder.encodeObject(self.photosURL, forKey: "photosURL")
        coder.encodeObject(self.categoryId, forKey: "categoryId")
        coder.encodeObject(self.category, forKey: "category")
    }
    
    // MARK: - NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Location()
        copy.id = id
        copy.name = name
        copy.imageURL = imageURL
        copy.mediumImageURL = mediumImageURL
        copy.thumbnailURL = thumbnailURL
        copy.latitude = latitude
        copy.longitude = longitude
        copy.address = address
        copy._description = _description
        copy.photosURL = photosURL
        copy.categoryId = categoryId
        copy.category = category
        return copy
    }
    
    // MARK: - Properties
    
    var oneLineAddress: String! {
        return address.stringByReplacingOccurrencesOfString("\n", withString: ", ",
            options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? Location {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: Location, rhs: Location) -> Bool {
    return lhs.id == rhs.id
}
