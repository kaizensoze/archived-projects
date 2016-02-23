//
//  MateFavorite.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/14/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

class MateFavorite: Mate {
    
    override init() {
        super.init()
    }
    
    override init(dict: NSDictionary) {
        super.init(dict: dict)
    }
    
    init(mate: Mate) {
        super.init()
        copyFromMate(mate)
    }
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
    }
    
    // MARK: - NSCopying
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! MateFavorite
        return copy
    }
    
    // MARK: - Copy from mate
    
    private func copyFromMate(mate: Mate) {
        id = mate.id
        firstName = mate.firstName
        lastName = mate.lastName
        price = mate.price
        when = mate.when
        imageURL = mate.imageURL
        originalImageURL = mate.originalImageURL
        image = mate.image
        _description = mate._description
        cats = mate.cats
        dogs = mate.dogs
        visible = mate.visible
        neighborhoodId = mate.neighborhoodId
        neighborhood = mate.neighborhood
        agentId = mate.agentId
        agent = mate.agent
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? MateFavorite {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: MateFavorite, rhs: MateFavorite) -> Bool {
    return lhs.id == rhs.id
}
