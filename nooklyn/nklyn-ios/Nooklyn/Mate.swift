//
//  Mate.swift
//  Nooklyn
//
//  Created by Joe Gallo on 9/23/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

class Mate: NSObject, NSCoding, NSCopying {
    var id = ""
    var firstName = ""
    var lastName = ""
    var price = 0
    var when = NSDate()
    var imageURL = ""
    var originalImageURL = ""
    var image = "" // base64 string field for uploading image file
    var _description = ""
    var cats = false
    var dogs = false
    var visible = true
    var neighborhoodId = ""
    var neighborhood: Neighborhood!
    var agentId = ""
    var agent: Agent!
    
    override init() {
        super.init()
    }
    
    init(dict: NSDictionary) {
        if let id = dict["id"] as? String { self.id = id }
        
        if let attributes = dict["attributes"] as? NSDictionary {
            if let firstName = attributes["first-name"] as? String { self.firstName = firstName }
            if let lastName = attributes["last-name"] as? String { self.lastName = lastName }
            if let price = attributes["price"] as? Int { self.price = price }
            if let when = attributes["when"] as? String { self.when = dateFromString(when) ?? NSDate() }
            if let imageURL = attributes["image-url"] as? String { self.imageURL = imageURL }
            if let originalImageURL = attributes["image"] as? String { self.originalImageURL = originalImageURL }
            if let description = attributes["description"] as? String { self._description = description }
            if let cats = attributes["cats"] as? Bool { self.cats = cats }
            if let dogs = attributes["dogs"] as? Bool { self.dogs = dogs }
            if let hidden = attributes["hidden"] as? Bool { self.visible = !hidden }
        }
        
        if let relationships = dict["relationships"] as? NSDictionary {
            // neighborhood
            if let neighborhoodDict = relationships["neighborhood"] as? NSDictionary {
                if let neighborhoodData = neighborhoodDict["data"] as? NSDictionary {
                    if let neighborhoodId = neighborhoodData["id"] as? String {
                        self.neighborhoodId = neighborhoodId
                    }
                }
            }
            
            // agent
            if let agentDict = relationships["agent"] as? NSDictionary {
                if let agentData = agentDict["data"] as? NSDictionary {
                    if let agentId = agentData["id"] as? String {
                        self.agentId = agentId
                    }
                }
            }
        }
    }
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        if let id = decoder.decodeObjectForKey("id") as? String { self.id = id }
        if let firstName = decoder.decodeObjectForKey("firstName") as? String { self.firstName = firstName }
        if let lastName = decoder.decodeObjectForKey("lastName") as? String { self.lastName = lastName }
        self.price = decoder.decodeIntegerForKey("price")
        if let when = decoder.decodeObjectForKey("when") as? NSDate { self.when = when }
        if let imageURL = decoder.decodeObjectForKey("imageURL") as? String { self.imageURL = imageURL }
        if let originalImageURL = decoder.decodeObjectForKey("originalImageURL") as? String { self.originalImageURL = originalImageURL }
        if let image = decoder.decodeObjectForKey("image") as? String { self.image = image }
        if let _description = decoder.decodeObjectForKey("_description") as? String { self._description = _description }
        self.cats = decoder.decodeBoolForKey("cats")
        self.dogs = decoder.decodeBoolForKey("dogs")
        self.visible = decoder.decodeBoolForKey("visible")
        if let neighborhoodId = decoder.decodeObjectForKey("neighborhoodId") as? String { self.neighborhoodId = neighborhoodId }
        if let neighborhood = decoder.decodeObjectForKey("neighborhood") as? Neighborhood { self.neighborhood = neighborhood }
        if let agentId = decoder.decodeObjectForKey("agentId") as? String { self.agentId = agentId }
        if let agent = decoder.decodeObjectForKey("agent") as? Agent { self.agent = agent }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.firstName, forKey: "firstName")
        coder.encodeObject(self.lastName, forKey: "lastName")
        coder.encodeInt(Int32(self.price), forKey: "price")
        coder.encodeObject(self.when, forKey: "when")
        coder.encodeObject(self.imageURL, forKey: "imageURL")
        coder.encodeObject(self.originalImageURL, forKey: "originalImageURL")
        coder.encodeObject(self.image, forKey: "image")
        coder.encodeObject(self._description, forKey: "_description")
        coder.encodeBool(self.cats, forKey: "cats")
        coder.encodeBool(self.dogs, forKey: "dogs")
        coder.encodeBool(self.visible, forKey: "visible")
        coder.encodeObject(self.neighborhoodId, forKey: "neighborhoodId")
        coder.encodeObject(self.neighborhood, forKey: "neighborhood")
        coder.encodeObject(self.agentId, forKey: "agentId")
        coder.encodeObject(self.agent, forKey: "agent")
    }
    
    // MARK: - NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Mate()
        copy.id = id
        copy.firstName = firstName
        copy.lastName = lastName
        copy.price = price
        copy.when = when
        copy.imageURL = imageURL
        copy.originalImageURL = originalImageURL
        copy.image = image
        copy._description = _description
        copy.cats = cats
        copy.dogs = dogs
        copy.visible = visible
        copy.neighborhoodId = neighborhoodId
        copy.neighborhood = neighborhood
        copy.agentId = agentId
        copy.agent = agent
        return copy
    }
    
    // MARK: - Properties
    
    var name: String! {
        return "\(firstName) \(lastName)"
    }
    
    var formattedPrice: String! {
        return formatPrice(price)
    }
    
    var formattedWhen: String! {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return stringFromDate(when, dateFormatter: dateFormatter)
    }
    
    var formattedWhenFull: String! {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        return stringFromDate(when, dateFormatter: dateFormatter)
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? Mate {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: Mate, rhs: Mate) -> Bool {
    return lhs.id == rhs.id
}
