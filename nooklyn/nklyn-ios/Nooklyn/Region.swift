//
//  Region.swift
//  Nooklyn
//
//  Created by Joe Gallo on 10/1/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

class Region: NSObject, NSCoding, NSCopying {
    var id = ""
    var name = ""
    var imageURL = ""
    var featured = false
    var latitude = 0.0
    var longitude = 0.0
    var neighborhoods = [Neighborhood]()
    
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
        }
    }
    
    // MARK: - NSCoding
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        
        if let id = decoder.decodeObjectForKey("id") as? String { self.id = id }
        if let name = decoder.decodeObjectForKey("name") as? String { self.name = name }
        if let imageURL = decoder.decodeObjectForKey("imageURL") as? String { self.imageURL = imageURL }
        self.featured = decoder.decodeBoolForKey("featured")
        self.latitude = decoder.decodeDoubleForKey("latitude")
        self.longitude = decoder.decodeDoubleForKey("longitude")
        if let neighborhoods = decoder.decodeObjectForKey("neighborhoods") as? [Neighborhood] { self.neighborhoods = neighborhoods }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.imageURL, forKey: "imageURL")
        coder.encodeBool(self.featured, forKey: "featured")
        coder.encodeDouble(self.latitude, forKey: "latitude")
        coder.encodeDouble(self.longitude, forKey: "longitude")
        coder.encodeObject(self.neighborhoods, forKey: "neighborhoods")
    }
    
    // MARK: - NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Region()
        copy.id = id
        copy.name = name
        copy.imageURL = imageURL
        copy.featured = featured
        copy.latitude = latitude
        copy.longitude = longitude
        copy.neighborhoods = neighborhoods
        return copy
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? Region {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: Region, rhs: Region) -> Bool {
    return lhs.id == rhs.id
}
