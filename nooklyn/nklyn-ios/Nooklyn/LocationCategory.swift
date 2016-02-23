//
//  LocationCategory.swift
//  Nooklyn
//
//  Created by Joe Gallo on 11/17/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

class LocationCategory: NSObject, NSCoding, NSCopying {
    var id = ""
    var name = ""
    var imageURL = ""
    var featured = false
    
    override init() {
        super.init()
    }
    
    init(dict: NSDictionary) {
        if let id = dict["id"] as? String { self.id = id }
        
        if let attributes = dict["attributes"] as? NSDictionary {
            if let name = attributes["name"] as? String { self.name = name }
            if let imageURL = attributes["image-url"] as? String { self.imageURL = imageURL }
            if let featured = attributes["featured"] as? Bool { self.featured = featured }
        }
    }
    
    // /locations.json
    init(dict2: NSDictionary) {
        if let id = dict2["id"] as? Int { self.id = String(id) }
        if let name = dict2["name"] as? String { self.name = name }
        if let image_file_name = dict2["image_file_name"] as? String {
            self.imageURL = "https://s3.amazonaws.com/nooklyn-pro/location_categories/\(id)/original/\(image_file_name)"
        }
        if let featured = dict2["featured"] as? Bool { self.featured = featured }
    }
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        if let id = decoder.decodeObjectForKey("id") as? String { self.id = id }
        if let name = decoder.decodeObjectForKey("name") as? String { self.name = name }
        if let imageURL = decoder.decodeObjectForKey("imageURL") as? String { self.imageURL = imageURL }
        self.featured = decoder.decodeBoolForKey("featured")
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.imageURL, forKey: "imageURL")
        coder.encodeBool(self.featured, forKey: "featured")
    }
    
    // MARK: - NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = LocationCategory()
        copy.id = id
        copy.name = name
        copy.imageURL = imageURL
        copy.featured = featured
        return copy
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? LocationCategory {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: LocationCategory, rhs: LocationCategory) -> Bool {
    return lhs.id == rhs.id
}