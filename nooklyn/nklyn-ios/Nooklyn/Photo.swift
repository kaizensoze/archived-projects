//
//  Photo.swift
//  Nooklyn
//
//  Created by Joe Gallo on 10/1/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

class Photo: NSObject, NSCoding, NSCopying {
    var id = ""
    var thumbnailURL = ""
    var imageURL = ""
    
    override init() {
        super.init()
    }
    
    init(dict: NSDictionary) {
        if let id = dict["id"] as? String { self.id = id }
        
        if let attributes = dict["attributes"] as? NSDictionary {
            if let thumbnailURL = attributes["thumbnail"] as? String { self.thumbnailURL = thumbnailURL }
            if let imageURL = attributes["image"] as? String { self.imageURL = imageURL }
        }
    }
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        if let id = decoder.decodeObjectForKey("id") as? String { self.id = id }
        if let thumbnailURL = decoder.decodeObjectForKey("thumbnailURL") as? String { self.thumbnailURL = thumbnailURL }
        if let imageURL = decoder.decodeObjectForKey("imageURL") as? String { self.imageURL = imageURL }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.thumbnailURL, forKey: "thumbnailURL")
        coder.encodeObject(self.imageURL, forKey: "imageURL")
    }
    
    // MARK: - NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Photo()
        copy.id = id
        copy.thumbnailURL = thumbnailURL
        copy.imageURL = imageURL
        return copy
    }

    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? Photo {
            return id == other.id
        } else {
            return false
        }
    }

    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: Photo, rhs: Photo) -> Bool {
    return lhs.id == rhs.id
}
