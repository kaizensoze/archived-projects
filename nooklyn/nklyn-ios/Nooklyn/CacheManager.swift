//
//  CacheManager.swift
//  Nooklyn
//
//  Created by Joe Gallo on 1/22/16.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

import UIKit

class CacheManager {
    
    static var loggedInAgentId: String?
    
    static var neighborhoodCache = [String: Neighborhood]()
    static var regionCache = [String: Region]()
    static var agentCache = [String: Agent]()
    
    static var listingNeighborhoodCache = [String: Neighborhood]()
    static var mateNeighborhoodCache = [String: Neighborhood]()
    
    static var amenities = [String]()
    
    // MARK: - Neighborhoods
    
    class func getNeighborhoods() -> [Neighborhood] {
        return Array(neighborhoodCache.values)
    }
    
    class func getNeighborhood(neighborhoodId: String) -> Neighborhood? {
        return neighborhoodCache[neighborhoodId]
    }
    
    class func saveNeighborhoods(neighborhoods: [Neighborhood]) {
        for neighborhood in neighborhoods {
            neighborhoodCache[neighborhood.id] = neighborhood
        }
    }
    
    // MARK: - Regions
    
    class func getRegions() -> [Region] {
        return Array(regionCache.values)
    }
    
    class func getRegion(regionId: String) -> Region? {
        return regionCache[regionId]
    }
    
    class func saveRegions(regions: [Region]) {
        for region in regions {
            regionCache[region.id] = region
        }
    }
    
    // MARK: - Agents
    
    class func getAgent(agentId: String) -> Agent? {
        return agentCache[agentId]
    }
    
    class func saveAgents(agents: [Agent]) {
        for agent in agents {
            agentCache[agent.id] = agent
        }
        
        // save logged in agent to disk
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            NSKeyedArchiver.archiveRootObject(loggedInAgent, toFile: getPath("loggedInAgent"))
        }
    }
    
    // MARK: - Listing neighborhoods
    
    class func getListingNeighborhoods() -> [Neighborhood] {
        return Array(listingNeighborhoodCache.values)
    }
    
    class func getListingNeighborhood(listingNeighborhoodId: String) -> Neighborhood? {
        return listingNeighborhoodCache[listingNeighborhoodId]
    }
    
    class func saveListingNeighborhoods(listingNeighborhoods: [Neighborhood]) {
        for listingNeighborhood in listingNeighborhoods {
            listingNeighborhoodCache[listingNeighborhood.id] = listingNeighborhood
        }
    }
    
    // MARK: - Mate neighborhoods
    
    class func getMateNeighborhoods() -> [Neighborhood] {
        return Array(mateNeighborhoodCache.values)
    }
    
    class func getMateNeighborhood(mateNeighborhoodId: String) -> Neighborhood? {
        return mateNeighborhoodCache[mateNeighborhoodId]
    }
    
    class func saveMateNeighborhoods(mateNeighborhoods: [Neighborhood]) {
        for mateNeighborhood in mateNeighborhoods {
            mateNeighborhoodCache[mateNeighborhood.id] = mateNeighborhood
        }
    }
    
    // MARK: - Listing favorites
    
    class func getListingFavorites() -> [ListingFavorite] {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            return Array(loggedInAgent.listingFavorites.values)
        }
        return [ListingFavorite]()
    }
    
    class func getListingFavorite(listingFavoriteId: String) -> ListingFavorite? {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            return loggedInAgent.listingFavorites[listingFavoriteId]
        }
        return nil
    }
    
    class func saveListingFavorites(listingFavorites: [ListingFavorite]) {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            for listingFavorite in listingFavorites {
                loggedInAgent.listingFavorites[listingFavorite.id] = listingFavorite
            }
            saveAgents([loggedInAgent])
        }
    }
    
    class func removeListingFavorite(listingFavoriteId: String) {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            loggedInAgent.listingFavorites.removeValueForKey(listingFavoriteId)
            saveAgents([loggedInAgent])
        }
    }
    
    class func clearListingFavorites() {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            loggedInAgent.listingFavorites.removeAll()
            saveAgents([loggedInAgent])
        }
    }
    
    // MARK: - Mate favorites
    
    class func getMateFavorites() -> [MateFavorite] {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            return Array(loggedInAgent.mateFavorites.values)
        }
        return [MateFavorite]()
    }
    
    class func getMateFavorite(mateFavoriteId: String) -> MateFavorite? {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            return loggedInAgent.mateFavorites[mateFavoriteId]
        }
        return nil
    }
    
    class func saveMateFavorites(mateFavorites: [MateFavorite]) {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            for mateFavorite in mateFavorites {
                loggedInAgent.mateFavorites[mateFavorite.id] = mateFavorite
            }
            saveAgents([loggedInAgent])
        }
    }
    
    class func removeMateFavorite(mateFavoriteId: String) {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            loggedInAgent.mateFavorites.removeValueForKey(mateFavoriteId)
            saveAgents([loggedInAgent])
        }
    }
    
    class func clearMateFavorites() {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            loggedInAgent.mateFavorites.removeAll()
            saveAgents([loggedInAgent])
        }
    }
    
    // MARK: - Location favorites
    
    class func getLocationFavorites() -> [LocationFavorite] {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            return Array(loggedInAgent.locationFavorites.values)
        }
        return [LocationFavorite]()
    }
    
    class func getLocationFavorite(locationFavoriteId: String) -> LocationFavorite? {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            return loggedInAgent.locationFavorites[locationFavoriteId]
        }
        return nil
    }
    
    class func saveLocationFavorites(locationFavorites: [LocationFavorite]) {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            for locationFavorite in locationFavorites {
                loggedInAgent.locationFavorites[locationFavorite.id] = locationFavorite
            }
            saveAgents([loggedInAgent])
        }
    }
    
    class func removeLocationFavorite(locationFavoriteId: String) {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            loggedInAgent.locationFavorites.removeValueForKey(locationFavoriteId)
            saveAgents([loggedInAgent])
        }
    }
    
    class func clearLocationFavorites() {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            loggedInAgent.locationFavorites.removeAll()
            saveAgents([loggedInAgent])
        }
    }
    
    // MARK: - Listing ignores
    
    class func getListingIgnores() -> [ListingIgnore] {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            return Array(loggedInAgent.listingIgnores.values)
        }
        return [ListingIgnore]()
    }
    
    class func getListingIgnore(listingIgnoreId: String) -> ListingIgnore? {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            return loggedInAgent.listingIgnores[listingIgnoreId]
        }
        return nil
    }
    
    class func saveListingIgnores(listingIgnores: [ListingIgnore]) {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            for listingIgnore in listingIgnores {
                loggedInAgent.listingIgnores[listingIgnore.id] = listingIgnore
            }
            saveAgents([loggedInAgent])
        }
    }
    
    class func clearListingIgnores() {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            loggedInAgent.listingIgnores.removeAll()
            saveAgents([loggedInAgent])
        }
    }
    
    // MARK: - Mate ignores
    
    class func getMateIgnores() -> [MateIgnore] {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            return Array(loggedInAgent.mateIgnores.values)
        }
        return [MateIgnore]()
    }
    
    class func getMateIgnore(mateIgnoreId: String) -> MateIgnore? {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            return loggedInAgent.mateIgnores[mateIgnoreId]
        }
        return nil
    }
    
    class func saveMateIgnores(mateIgnores: [MateIgnore]) {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            for mateIgnore in mateIgnores {
                loggedInAgent.mateIgnores[mateIgnore.id] = mateIgnore
            }
            saveAgents([loggedInAgent])
        }
    }
    
    class func clearMateIgnores() {
        if let _loggedInAgentId = loggedInAgentId, loggedInAgent = getAgent(_loggedInAgentId) {
            loggedInAgent.mateIgnores.removeAll()
            saveAgents([loggedInAgent])
        }
    }
    
    // MARK: - Amenities
    
    class func setAmenities(amenities: [String]) {
        self.amenities = amenities
    }
    
    class func getAmenities() -> [String] {
        return amenities
    }
    
    // MARK: - Load logged in agent from disk
    
    class func loadLoggedInAgentFromDisk() {
        // logged in agent
        if let loggedInAgent = NSKeyedUnarchiver.unarchiveObjectWithFile(getPath("loggedInAgent")) as? Agent {
            loggedInAgentId = loggedInAgent.id
            saveAgents([loggedInAgent])
        }
    }
    
    // MARK: - Remove logged in agent
    
    class func removeLoggedInAgent() {
        guard let _loggedInAgentId = loggedInAgentId else {
            return
        }
        
        // remove from agent cache
        agentCache.removeValueForKey(_loggedInAgentId)
        
        // set loggedInAgentId to nil
        loggedInAgentId = nil
        
        // remove from disk
        let path = getPath("loggedInAgent")
        
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(path) {
            do {
                try fileManager.removeItemAtPath(path)
            } catch {
                print("Unable to remove logged in agent on disk.")
            }
        }
    }
    
    // MARK: - Get write path
    
    private class func getPath(key: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let dir = paths[0] as NSString
        let path = dir.stringByAppendingPathComponent(key)
        return path
    }
}
