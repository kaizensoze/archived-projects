//
//  ListingPhoto.swift
//  Nooklyn
//
//  Created by Joe Gallo on 10/1/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

class ListingPhoto: Photo {
    var featured = false
    
    override init() {
        super.init()
    }
    
    override init(dict: NSDictionary) {
        if let attributes = dict["attributes"] as? NSDictionary {
            if let featured = attributes["featured"] as? Bool { self.featured = featured }
        }
        super.init(dict: dict)
    }
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        if let featured = decoder.decodeObjectForKey("featured") as? Bool { self.featured = featured }
        super.init(coder: decoder)
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeObject(self.featured, forKey: "featured")
    }
    
    // MARK: - NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! ListingPhoto
        copy.featured = featured
        return copy
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? ListingPhoto {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: ListingPhoto, rhs: ListingPhoto) -> Bool {
    return lhs.id == rhs.id
}
