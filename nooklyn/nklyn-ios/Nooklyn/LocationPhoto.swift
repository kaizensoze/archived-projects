//
//  LocationPhoto.swift
//  Nooklyn
//
//  Created by Joe Gallo on 10/1/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

class LocationPhoto: Photo {
    var caption: String?
    
    override init() {
        super.init()
    }
    
    override init(dict: NSDictionary) {
        if let attributes = dict["attributes"] as? NSDictionary {
            if let caption = attributes["caption"] as? String { self.caption = caption }
        }
        super.init(dict: dict)
    }
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        if let caption = decoder.decodeObjectForKey("caption") as? String { self.caption = caption }
        super.init(coder: decoder)
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        self.encodeWithCoder(coder)
        coder.encodeObject(self.caption, forKey: "caption")
    }
    
    // MARK: - NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! LocationPhoto
        copy.caption = caption
        return copy
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? LocationPhoto {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: LocationPhoto, rhs: LocationPhoto) -> Bool {
    return lhs.id == rhs.id
}
