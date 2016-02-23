//
//  Listing.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/2/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

class Listing: NSObject, NSCoding, NSCopying {
    var id = ""
    var bedrooms = 0
    var bathrooms = 0
    var price = 0
    var imageURL = ""
    var mediumImageURL = ""
    var thumbnailURL = ""
    var status = ""
    var statusVal = 0
    var _private = false
    var featured = false
    var heartsCount = 0
    var latitude = 0.0
    var longitude = 0.0
    var residential = false
    var rental = false
    var listingDescription = ""
    var amenities = ""
    var subwayLines = ""
    var subwayStations = ""
    var address = ""
    var apartment = ""
    var access = ""
    var listingAgentName = ""
    var term = ""
    var dateAvailable = ""
    var photosURL = ""
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
            if let bedrooms = attributes["bedrooms"] as? Int { self.bedrooms = bedrooms }
            if let bathrooms = attributes["bathrooms"] as? Int { self.bathrooms = bathrooms }
            if let price = attributes["price"] as? Int { self.price = price }
            if let imageURL = attributes["image"] as? String { self.imageURL = imageURL }
            if let mediumImageURL = attributes["medium-image"] as? String { self.mediumImageURL = mediumImageURL }
            if let thumbnailURL = attributes["primary-thumbnail"] as? String { self.thumbnailURL = thumbnailURL }
            if let status = attributes["status"] as? String { self.status = status }
            if let _private = attributes["private"] as? Bool { self._private = _private }
            if let featured = attributes["featured"] as? Bool { self.featured = featured }
            if let heartsCount = attributes["hearts-count"] as? Int { self.heartsCount = heartsCount }
            if let latitude = attributes["latitude"] as? Double { self.latitude = latitude }
            if let longitude = attributes["longitude"] as? Double { self.longitude = longitude }
            if let residential = attributes["residential"] as? Bool { self.residential = residential }
            if let rental = attributes["rental"] as? Bool { self.rental = rental }
            if let listingDescription = attributes["description"] as? String { self.listingDescription = listingDescription }
            if let amenities = attributes["amenities"] as? String { self.amenities = amenities }
            if let subwayLineURL = attributes["subway-line-url"] as? String { SUBWAY_LINE_URL = subwayLineURL }
            if let subwayLines = attributes["subway-line"] as? String { self.subwayLines = subwayLines.strip() }
            if let subwayStations = attributes["station"] as? String { self.subwayStations = subwayStations }
            if let address = attributes["address"] as? String { self.address = address }
            if let apartment = attributes["apartment"] as? String { self.apartment = apartment }
            if let access = attributes["access"] as? String { self.access = access }
            if let listingAgentName = attributes["listing-agent-name"] as? String { self.listingAgentName = listingAgentName }
            if let term = attributes["term"] as? String { self.term = term }
            if let dateAvailable = attributes["date-available"] as? String { self.dateAvailable = dateAvailable }
        }
        
        if let relationships = dict["relationships"] as? NSDictionary {
            // photos
            if let photos = relationships["photos"] as? NSDictionary {
                if let links = photos["links"] as? NSDictionary {
                    if let photosURL = links["related"] as? String { self.photosURL = photosURL }
                }
            }
            
            // neighborhood (NOTE: important to set neighborhood here so favorite object can utilize it)
            if let neighborhoodDict = relationships["neighborhood"] as? NSDictionary {
                if let neighborhoodData = neighborhoodDict["data"] as? NSDictionary {
                    if let neighborhoodId = neighborhoodData["id"] as? String {
                        self.neighborhoodId = neighborhoodId
                    }
                }
            }
            
            // agent
            if let agentDict = relationships["sales-agent"] as? NSDictionary {
                if let agentData = agentDict["data"] as? NSDictionary {
                    if let agentId = agentData["id"] as? String {
                        self.agentId = agentId
                    }
                }
            }
        }
        
        // NOTE: Set instance variables, then super.init(), then instance methods. (http://goo.gl/0T2qvu)
        
        super.init()
        
        self.statusVal = _statusVal(self.status)
        configure()
    }
    
    // /listings.json
    init(dict2: NSDictionary) {
        if let id = dict2["id"] as? Int { self.id = String(id) }
        if let bedrooms = dict2["bedrooms"] as? Int { self.bedrooms = bedrooms }
        if let bathrooms = dict2["bathrooms"] as? Int { self.bathrooms = bathrooms }
        if let price = dict2["price"] as? String {
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            if let priceNumber = formatter.numberFromString(price) {
                self.price = Int(priceNumber)
            }
        }
        if let imageURL = dict2["photo_url"] as? String { self.imageURL = imageURL }
        if let mediumImageURL = dict2["medium_photo_url"] as? String { self.mediumImageURL = mediumImageURL }
        if let thumbnailURL = dict2["thumbnail_url"] as? String { self.thumbnailURL = thumbnailURL }
        if let latitude = dict2["latitude"] as? Double { self.latitude = latitude }
        if let longitude = dict2["longitude"] as? Double { self.longitude = longitude }
        if let status = dict2["status"] as? String { self.status = status }
        if let residential = dict2["residential"] as? Bool { self.residential = residential }
        if let rental = dict2["rental"] as? Bool { self.rental = rental }
        if let listingDescription = dict2["description"] as? String { self.listingDescription = listingDescription }
        if let amenities = dict2["amenities"] as? String { self.amenities = amenities }
        if let subwayLineURL = dict2["subway_line_url"] as? String { SUBWAY_LINE_URL = subwayLineURL }
        if let subwayLines = dict2["subway_line"] as? String { self.subwayLines = subwayLines.strip() }
        if let subwayStations = dict2["station"] as? String { self.subwayStations = subwayStations }
        if let address = dict2["address"] as? String { self.address = address }
        if let apartment = dict2["apartment"] as? String { self.apartment = apartment }
        if let access = dict2["access"] as? String { self.access = access }
        if let listingAgentName = dict2["listing_agent_name"] as? String { self.listingAgentName = listingAgentName }
        if let term = dict2["term"] as? String { self.term = term }
        if let dateAvailable = dict2["date_available"] as? String { self.dateAvailable = dateAvailable }
        
        self.photosURL = "\(SITE_DOMAIN)\(API_PREFIX)listings/\(id)/photos"
        
        // neighborhood
        if let neighborhoodId = dict2["neighborhood_id"] as? Int {
            self.neighborhoodId = String(neighborhoodId)
        }
        
        // agent
        if let agentId = dict2["sales_agent_id"] as? Int {
            self.agentId = String(agentId)
        }
        
        super.init()
        
        self.statusVal = _statusVal(self.status)
        configure()
    }
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        if let id = decoder.decodeObjectForKey("id") as? String { self.id = id }
        self.bedrooms = decoder.decodeIntegerForKey("bedrooms")
        self.bathrooms = decoder.decodeIntegerForKey("bathrooms")
        self.price = decoder.decodeIntegerForKey("price")
        if let imageURL = decoder.decodeObjectForKey("imageURL") as? String { self.imageURL = imageURL }
        if let mediumImageURL = decoder.decodeObjectForKey("mediumImageURL") as? String { self.mediumImageURL = mediumImageURL }
        if let thumbnailURL = decoder.decodeObjectForKey("thumbnailURL") as? String { self.thumbnailURL = thumbnailURL }
        if let status = decoder.decodeObjectForKey("status") as? String { self.status = status }
        self.statusVal = decoder.decodeIntegerForKey("statusVal")
        self._private = decoder.decodeBoolForKey("_private")
        self.featured = decoder.decodeBoolForKey("featured")
        self.heartsCount = decoder.decodeIntegerForKey("heartsCount")
        self.latitude = decoder.decodeDoubleForKey("latitude")
        self.longitude = decoder.decodeDoubleForKey("longitude")
        self.residential = decoder.decodeBoolForKey("residential")
        self.rental = decoder.decodeBoolForKey("rental")
        if let listingDescription = decoder.decodeObjectForKey("listingDescription") as? String { self.listingDescription = listingDescription }
        if let amenities = decoder.decodeObjectForKey("amenities") as? String { self.amenities = amenities }
        if let subwayLines = decoder.decodeObjectForKey("subwayLines") as? String { self.subwayLines = subwayLines }
        if let subwayStations = decoder.decodeObjectForKey("subwayStations") as? String { self.subwayStations = subwayStations }
        if let address = decoder.decodeObjectForKey("address") as? String { self.address = address }
        if let apartment = decoder.decodeObjectForKey("apartment") as? String { self.apartment = apartment }
        if let access = decoder.decodeObjectForKey("access") as? String { self.access = access }
        if let listingAgentName = decoder.decodeObjectForKey("listingAgentName") as? String { self.listingAgentName = listingAgentName }
        if let term = decoder.decodeObjectForKey("term") as? String { self.term = term }
        if let dateAvailable = decoder.decodeObjectForKey("dateAvailable") as? String { self.dateAvailable = dateAvailable }
        if let photosURL = decoder.decodeObjectForKey("photosURL") as? String { self.photosURL = photosURL }
        if let neighborhoodId = decoder.decodeObjectForKey("neighborhoodId") as? String { self.neighborhoodId = neighborhoodId }
        if let neighborhood = decoder.decodeObjectForKey("neighborhood") as? Neighborhood { self.neighborhood = neighborhood }
        if let agentId = decoder.decodeObjectForKey("agentId") as? String { self.agentId = agentId }
        if let agent = decoder.decodeObjectForKey("agent") as? Agent { self.agent = agent }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeInt(Int32(self.bedrooms), forKey: "bedrooms")
        coder.encodeInt(Int32(self.bathrooms), forKey: "bathrooms")
        coder.encodeInt(Int32(self.price), forKey: "price")
        coder.encodeObject(self.imageURL, forKey: "imageURL")
        coder.encodeObject(self.mediumImageURL, forKey: "mediumImageURL")
        coder.encodeObject(self.thumbnailURL, forKey: "thumbnailURL")
        coder.encodeObject(self.status, forKey: "status")
        coder.encodeInt(Int32(self.statusVal), forKey: "statusVal")
        coder.encodeBool(self._private, forKey: "_private")
        coder.encodeBool(self.featured, forKey: "featured")
        coder.encodeInt(Int32(self.heartsCount), forKey: "heartsCount")
        coder.encodeDouble(self.latitude, forKey: "latitude")
        coder.encodeDouble(self.longitude, forKey: "longitude")
        coder.encodeBool(self.residential, forKey: "residential")
        coder.encodeBool(self.rental, forKey: "rental")
        coder.encodeObject(self.listingDescription, forKey: "listingDescription")
        coder.encodeObject(self.amenities, forKey: "amenities")
        coder.encodeObject(self.subwayLines, forKey: "subwayLines")
        coder.encodeObject(self.subwayStations, forKey: "subwayStations")
        coder.encodeObject(self.address, forKey: "address")
        coder.encodeObject(self.apartment, forKey: "apartment")
        coder.encodeObject(self.access, forKey: "access")
        coder.encodeObject(self.listingAgentName, forKey: "listingAgentName")
        coder.encodeObject(self.term, forKey: "term")
        coder.encodeObject(self.dateAvailable, forKey: "dateAvailable")
        coder.encodeObject(self.photosURL, forKey: "photosURL")
        coder.encodeObject(self.neighborhoodId, forKey: "neighborhoodId")
        coder.encodeObject(self.neighborhood, forKey: "neighborhood")
        coder.encodeObject(self.agentId, forKey: "agentId")
        coder.encodeObject(self.agent, forKey: "agent")
    }
    
    // MARK: - NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Listing()
        copy.id = id
        copy.bedrooms = bedrooms
        copy.bathrooms = bathrooms
        copy.price = price
        copy.imageURL = imageURL
        copy.mediumImageURL = mediumImageURL
        copy.thumbnailURL = thumbnailURL
        copy.status = status
        copy.statusVal = statusVal
        copy._private = _private
        copy.featured = featured
        copy.heartsCount = heartsCount
        copy.latitude = latitude
        copy.longitude = longitude
        copy.residential = residential
        copy.rental = rental
        copy.listingDescription = listingDescription
        copy.amenities = amenities
        copy.subwayLines = subwayLines
        copy.subwayStations = subwayStations
        copy.address = address
        copy.apartment = apartment
        copy.access = access
        copy.listingAgentName = listingAgentName
        copy.term = term
        copy.dateAvailable = dateAvailable
        copy.photosURL = photosURL
        copy.neighborhoodId = neighborhoodId
        copy.neighborhood = neighborhood
        copy.agentId = agentId
        copy.agent = agent
        return copy
    }
    
    // MARK: - Configure
    
    func configure() {
    }
    
    // MARK: - Properties
    
    var formattedPrice: String! {
        return formatPrice(price)
    }
    
    var amenitiesList: [String] {
        return amenities
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            .componentsSeparatedByString("\r\n")
    }
    
    var subwayLinesList: [String] {
        let trimmedSubwayLinesString = subwayLines.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let subwayLineArray = trimmedSubwayLinesString.componentsSeparatedByString(" ")
        return Util.sortedSubwayLines(subwayLineArray)
    }
    
    func formattedSubwayLineURL(subwayLine: String) -> String {
        return Util.formattedSubwayLineURL(subwayLine)
    }
    
    var available: Bool {
        return status == "Available"
    }
    
    private func _statusVal(_status: String) -> Int {
        switch _status {
        case "Available":
            return 1
        case "Application Pending":
            return 2
        case "Rented":
            return 3
        default:
            return 4
        }
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? Listing {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: Listing, rhs: Listing) -> Bool {
    return lhs.id == rhs.id
}

var SUBWAY_LINE_URL = ""
