//
//  Agent.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/2/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

class Agent: NSObject, NSCoding, NSCopying {
    var id = ""
    var firstName = ""
    var lastName = ""
    var phoneNumber = ""
    var thumbnailURL = ""
    var onProbation = false
    var suspended = false
    var employee = false
    var facebookAuthenticated = false
    var apiToken = ""
    
    var mate: Mate?
    
    var listingFavorites = [String: ListingFavorite]()
    var mateFavorites = [String: MateFavorite]()
    var locationFavorites = [String: LocationFavorite]()
    
    var listingIgnores = [String: ListingIgnore]()
    var mateIgnores = [String: MateIgnore]()
    
    override init() {
        super.init()
    }
    
    init(dict: NSDictionary) {
        if let id = dict["id"] as? String { self.id = id }
        
        if let attributes = dict["attributes"] as? NSDictionary {
            if let firstName = attributes["first-name"] as? String { self.firstName = firstName }
            if let lastName = attributes["last-name"] as? String { self.lastName = lastName }
            if let phoneNumber = attributes["phone"] as? String { self.phoneNumber = phoneNumber }
            if let thumbnailURL = attributes["thumbnail"] as? String { self.thumbnailURL = thumbnailURL }
            if let onProbation = attributes["on-probation"] as? Bool { self.onProbation = onProbation }
            if let suspended = attributes["suspended"] as? Bool { self.suspended = suspended }
            if let employee = attributes["employee"] as? Bool { self.employee = employee }
            if let facebookAuthenticated = attributes["facebook-authenticated"] as? Bool { self.facebookAuthenticated = facebookAuthenticated }
        }
    }
    
    // MARK: - NSCoding
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        
        if let id = decoder.decodeObjectForKey("id") as? String { self.id = id }
        if let firstName = decoder.decodeObjectForKey("firstName") as? String { self.firstName = firstName }
        if let lastName = decoder.decodeObjectForKey("lastName") as? String { self.lastName = lastName }
        if let phoneNumber = decoder.decodeObjectForKey("phoneNumber") as? String { self.phoneNumber = phoneNumber }
        if let thumbnailURL = decoder.decodeObjectForKey("thumbnailURL") as? String { self.thumbnailURL = thumbnailURL }
        self.onProbation = decoder.decodeBoolForKey("onProbation")
        self.suspended = decoder.decodeBoolForKey("suspended")
        self.employee = decoder.decodeBoolForKey("employee")
        self.facebookAuthenticated = decoder.decodeBoolForKey("facebookAuthenticated")
        if let apiToken = decoder.decodeObjectForKey("apiToken") as? String { self.apiToken = apiToken }
        if let mate = decoder.decodeObjectForKey("mate") as? Mate { self.mate = mate }
        if let listingFavorites = decoder.decodeObjectForKey("listingFavorites") as? [String: ListingFavorite] { self.listingFavorites = listingFavorites }
        if let mateFavorites = decoder.decodeObjectForKey("mateFavorites") as? [String: MateFavorite] { self.mateFavorites = mateFavorites }
        if let locationFavorites = decoder.decodeObjectForKey("locationFavorites") as? [String: LocationFavorite] { self.locationFavorites = locationFavorites }
        if let listingIgnores = decoder.decodeObjectForKey("listingIgnores") as? [String: ListingIgnore] { self.listingIgnores = listingIgnores }
        if let mateIgnores = decoder.decodeObjectForKey("mateIgnores") as? [String: MateIgnore] { self.mateIgnores = mateIgnores }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.firstName, forKey: "firstName")
        coder.encodeObject(self.lastName, forKey: "lastName")
        coder.encodeObject(self.phoneNumber, forKey: "phoneNumber")
        coder.encodeObject(self.thumbnailURL, forKey: "thumbnailURL")
        coder.encodeBool(self.onProbation, forKey: "onProbation")
        coder.encodeBool(self.suspended, forKey: "suspended")
        coder.encodeBool(self.employee, forKey: "employee")
        coder.encodeBool(self.facebookAuthenticated, forKey: "facebookAuthenticated")
        coder.encodeObject(self.apiToken, forKey: "apiToken")
        coder.encodeObject(self.mate, forKey: "mate")
        coder.encodeObject(self.listingFavorites, forKey: "listingFavorites")
        coder.encodeObject(self.mateFavorites, forKey: "mateFavorites")
        coder.encodeObject(self.locationFavorites, forKey: "locationFavorites")
        coder.encodeObject(self.listingIgnores, forKey: "listingIgnores")
        coder.encodeObject(self.mateIgnores, forKey: "mateIgnores")
    }
    
    // MARK: - NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Agent()
        copy.id = id
        copy.firstName = firstName
        copy.lastName = lastName
        copy.phoneNumber = phoneNumber
        copy.thumbnailURL = thumbnailURL
        copy.onProbation = onProbation
        copy.suspended = suspended
        copy.employee = employee
        copy.facebookAuthenticated = facebookAuthenticated
        copy.apiToken = apiToken
        copy.mate = mate
        copy.listingFavorites = listingFavorites
        copy.mateFavorites = mateFavorites
        copy.locationFavorites = locationFavorites
        copy.listingIgnores = listingIgnores
        copy.mateIgnores = mateIgnores
        return copy
    }
    
    // MARK: - Properties
    
    var name: String! {
        return "\(firstName) \(lastName)"
    }
    
    var shortName: String! {
        var _shortName = firstName
        if !lastName.isEmpty {
            _shortName += " \(lastName.uppercaseString[lastName.startIndex.advancedBy(0)])."
        }
        return _shortName
    }
    
    var formattedPhoneNumber: String? {
        let stringArray = phoneNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let formattedPhone = stringArray.joinWithSeparator("")
        if formattedPhone.characters.count < 7 {
            return nil
        }
        return formattedPhone
    }
    
    func hasPhoneNumber() -> Bool {
        if let _ = formattedPhoneNumber {
            return true
        }
        return false
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? Agent {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: Agent, rhs: Agent) -> Bool {
    return lhs.id == rhs.id
}
