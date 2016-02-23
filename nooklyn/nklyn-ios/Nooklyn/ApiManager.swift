//
//  ApiManager.swift
//  Nooklyn
//
//  Created by Joe Gallo on 8/16/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit

let API_PREFIX = "/api/v1/"

class ApiManager {
    
    // MARK: - Get neighborhoods
    
    class func getNeighborhoods(completion: (neighborhoods: [Neighborhood]) -> Void) {
        Alamofire.request(.GET, SITE_DOMAIN + API_PREFIX + "neighborhoods?include=region").responseJSON { response in
            var neighborhoods = [Neighborhood]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    showNetworkingErrorAlert(response)
                    completion(neighborhoods: neighborhoods)
                    return
                }
                
                // regions
                var regions = [String: Region]()
                if let includedArray = JSON["included"] as? NSArray {
                    for includedDict in (includedArray as? [NSDictionary])! {
                        let type = includedDict["type"] as! String
                        if type == "regions" {
                            let region = Region(dict: includedDict)
                            regions[region.id] = region
                        }
                    }
                }
                
                // neighborhoods
                if let neighborhoodsArray = JSON["data"] as? NSArray {
                    for neighborhoodDict in (neighborhoodsArray as? [NSDictionary])! {
                        let neighborhood = Neighborhood(dict: neighborhoodDict)
                        neighborhood.region = regions[neighborhood.regionId]
                        neighborhood.region.neighborhoods.append(neighborhood)
                        neighborhoods.append(neighborhood)
                    }
                }
                
                completion(neighborhoods: neighborhoods)
            } else {
                showNetworkingErrorAlert(response)
                completion(neighborhoods: neighborhoods)
            }
        }
    }
    
    // MARK: - Get listings
    
    class func getListings(completion: (listings: [Listing]) -> Void) {
        let urlPart = "listings?filter[status]=Available&filter[residential]=true&filter[private]=false&include=neighborhood,sales-agent"
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + urlPart)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            var listings = [Listing]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    showNetworkingErrorAlert(response)
                    completion(listings: listings)
                    return
                }
                
                // neighborhoods, agents
                var neighborhoods = [String: Neighborhood]()
                var agents = [String: Agent]()
                if let includedArray = JSON["included"] as? NSArray {
                    for includedDict in (includedArray as? [NSDictionary])! {
                        let type = includedDict["type"] as! String
                        if type == "neighborhoods" {
                            let neighborhood = Neighborhood(dict: includedDict)
                            neighborhoods[neighborhood.id] = neighborhood
                        } else if type == "agents" {
                            let agent = Agent(dict: includedDict)
                            agents[agent.id] = agent
                        }
                    }
                }
                
                // cache agents
                CacheManager.saveAgents(Array(Set(agents.values)))
                
                // listings
                if let listingsArray = JSON["data"] as? NSArray {
                    for listingDict in (listingsArray as? [NSDictionary])! {
                        let listing = Listing(dict: listingDict)
                        listing.neighborhood = neighborhoods[listing.neighborhoodId]
                        listing.agent = agents[listing.agentId]
                        listings.append(listing)
                    }
                }
                
                completion(listings: listings)
            } else {
                showNetworkingErrorAlert(response)
                completion(listings: listings)
            }
        }
    }
    
    // MARK: - Get listing photos
    
    class func getListingPhotos(listing listing: Listing, completion: (photos: [ListingPhoto]) -> Void) {
        Alamofire.request(.GET, listing.photosURL).responseJSON { response in
            var photos = [ListingPhoto]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    print("ERROR: Failed to get listing photos.")
                    completion(photos: photos)
                    return
                }
                
                if let photosArray = JSON["data"] as? NSArray {
                    for photoDict in (photosArray as? [NSDictionary])! {
                        let listingPhoto = ListingPhoto(dict: photoDict)
                        photos.append(listingPhoto)
                    }
                    completion(photos: photos)
                }
            } else {
                print("ERROR: Failed to get listing photos.")
                completion(photos: photos)
            }
        }
    }
    
    // MARK: - Get location photos
    
    class func getLocationPhotos(location location: Location, completion: (photos: [LocationPhoto]) -> Void) {
        Alamofire.request(.GET, location.photosURL).responseJSON { response in
            var photos = [LocationPhoto]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    print("ERROR: Failed to get location photos.")
                    completion(photos: photos)
                    return
                }
                
                if let photosArray = JSON["data"] as? NSArray {
                    for photoDict in (photosArray as? [NSDictionary])! {
                        let locationPhoto = LocationPhoto(dict: photoDict)
                        photos.append(locationPhoto)
                    }
                    completion(photos: photos)
                }
            } else {
                print("ERROR: Failed to get location photos.")
                completion(photos: photos)
            }
        }
    }
    
    // MARK: - Get nearby listings
    
    class func getNearbyListings(latitude latitude: Double, longitude: Double, radius: Double = 1.0, completion: (listings: [Listing]) -> Void) {
        let URL = NSURL(string: SITE_DOMAIN + "/listings.json")!
        var mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        let parameters: [String: AnyObject] = [
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius,
            "residential_only": true
        ]
        let encoding = Alamofire.ParameterEncoding.URL
        (mutableURLRequest, _) = encoding.encode(mutableURLRequest, parameters: parameters)
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            var listings = [Listing]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    print("ERROR: Failed to get nearby listings.")
                    completion(listings: listings)
                    return
                }
                
                if let listingsArray = JSON["listings"] as? NSArray {
                    for listingDict in (listingsArray as? [NSDictionary])! {
                        let listing = Listing(dict2: listingDict)
                        listing.neighborhood = CacheManager.getNeighborhood(listing.neighborhoodId)
                        listing.agent = CacheManager.getAgent(listing.agentId)
                        listings.append(listing)
                    }
                }
                
                completion(listings: listings)
            } else {
                print("ERROR: Failed to get nearby listings.")
                completion(listings: listings)
            }
        }
    }
    
    // MARK: - Get nearby locations
    
    class func getNearbyLocations(latitude latitude: Double, longitude: Double, radius: Double = 1.0, completion: (locations: [Location]) -> Void) {
        let parameters = [
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius
        ]
        Alamofire.request(.GET, SITE_DOMAIN + "/locations.json", parameters: parameters).responseJSON { response in
            var locations = [Location]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    print("ERROR: Failed to get nearby locations.")
                    completion(locations: locations)
                    return
                }
                
                if let locationsArray = JSON["locations"] as? NSArray {
                    for locationDict in (locationsArray as? [NSDictionary])! {
                        let location = Location(dict2: locationDict)
                        locations.append(location)
                    }
                }
                
                completion(locations: locations)
            } else {
                print("ERROR: Failed to get nearby locations.")
                completion(locations: locations)
            }
        }
    }
    
    // MARK: - Get neighborhood locations
    
    class func getNeighborhoodLocations(neighborhoodId neighborhoodId: String, locationCategoryId: String? = nil, completion: (locations: [Location]) -> Void) {
        // location category id is optional
        var urlPart: String!
        if let _locationCategoryId = locationCategoryId {
            urlPart = "locations?filter[neighborhood-id]=\(neighborhoodId)&filter[location-category-id]=\(_locationCategoryId)&include=location-category"
        } else {
            urlPart = "locations?filter[neighborhood-id]=\(neighborhoodId)&include=location-category"
        }
        
        Alamofire.request(.GET, SITE_DOMAIN + API_PREFIX + urlPart).responseJSON { response in
            var locations = [Location]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    print("ERROR: Failed to get neighborhood locations.")
                    completion(locations: locations)
                    return
                }
                
                // location categories
                var locationCategoryDict = [String: LocationCategory]()
                if let includedArray = JSON["included"] as? NSArray {
                    for includedDict in (includedArray as? [NSDictionary])! {
                        let type = includedDict["type"] as! String
                        if type == "location-categories" {
                            let locationCategory = LocationCategory(dict: includedDict)
                            locationCategoryDict[locationCategory.id] = locationCategory
                        }
                    }
                }
                
                // locations
                if let locationsArray = JSON["data"] as? NSArray {
                    for locationDict in (locationsArray as? [NSDictionary])! {
                        let location = Location(dict: locationDict)
                        location.category = locationCategoryDict[location.categoryId]
                        locations.append(location)
                    }
                }
                
                completion(locations: locations)
            } else {
                print("ERROR: Failed to get neighborhood locations.")
                completion(locations: locations)
            }
        }
    }
    
    // MARK: - Get neighborhood location categories
    
    class func getNeighborhoodLocationCategories(neighborhoodId neighborhoodId: String, completion: (locationCategories: [LocationCategory]) -> Void) {
        Alamofire.request(.GET, SITE_DOMAIN + API_PREFIX + "neighborhoods/\(neighborhoodId)/location-categories").responseJSON { response in
            var locationCategories = [LocationCategory]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    print("ERROR: Failed to get neighborhood location categories.")
                    completion(locationCategories: locationCategories)
                    return
                }
                
                // location categories
                if let locationCategoriesArray = JSON["data"] as? NSArray {
                    for locationCategoryDict in (locationCategoriesArray as? [NSDictionary])! {
                        let locationCategory = LocationCategory(dict: locationCategoryDict)
                        locationCategories.append(locationCategory)
                    }
                }
                
                // sort by name
                locationCategories.sortInPlace({ $0.name < $1.name })
                
                completion(locationCategories: locationCategories)
            } else {
                print("ERROR: Failed to get neighborhood location categories.")
                completion(locationCategories: locationCategories)
            }
        }
    }
    
    // MARK: - Get neighborhood featured locations
    
    class func getNeighborhoodFeaturedLocations(neighborhoodId neighborhoodId: String, completion: (locations: [Location]) -> Void) {
        let urlPart = "locations?filter[neighborhood-id]=\(neighborhoodId)&filter[featured]=true"
        Alamofire.request(.GET, SITE_DOMAIN + API_PREFIX + urlPart).responseJSON { response in
            var locations = [Location]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    print("ERROR: Failed to get neighborhood location categories.")
                    completion(locations: locations)
                    return
                }

                // locations
                if let locationsArray = JSON["data"] as? NSArray {
                    for locationDict in (locationsArray as? [NSDictionary])! {
                        let location = Location(dict: locationDict)
                        locations.append(location)
                    }
                }
                
                completion(locations: locations)
            } else {
                print("ERROR: Failed to get neighborhood location categories.")
                completion(locations: locations)
            }
        }
    }
    
    // MARK: - Signup
    
    class func signup(userInfo: [String: String], completion: (signupSucceeded: Bool, errorMsg: String) -> Void) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "agents")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "data": [
                "type": "agents",
                "attributes": [
                    "email": userInfo["email"]!,
                    "password": userInfo["password"]!,
                    "first-name": userInfo["first-name"]!,
                    "last-name": userInfo["last-name"]!,
                    "phone": userInfo["phone"]!
                ]
            ]
        ]
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            if let JSON = response.result.value {
                if let errors = JSON["errors"] as? NSArray,
                       error = errors[0] as? NSDictionary {
                    let errorMsg = error["title"] as! String
                    completion(signupSucceeded: false, errorMsg: errorMsg)
                } else {
                    // auto-login on successful signup
                    login(userInfo["email"]!, password: userInfo["password"]!) { loginSucceeded in
                        if loginSucceeded {
                            completion(signupSucceeded: true, errorMsg: "")
                        }
                    }
                }
            } else {
                completion(signupSucceeded: false, errorMsg: "")
            }
        }
    }
    
    // MARK: - Login
    
    class func login(email: String, password: String, completion: (loginSucceeded: Bool) -> Void) {
        let parameters = [
            "session": [
                "email": email,
                "password": password
            ]
        ]
        Alamofire.request(.POST, SITE_DOMAIN + API_PREFIX + "sessions", parameters: parameters).responseJSON { response in
            if let JSON = response.result.value {
                if let sessionDict = JSON["session"] as? NSDictionary,
                       sessionLinksDict = sessionDict["links"] as? NSDictionary,
                       apiToken = sessionDict["id"] as? String {
                    let agentId = String(sessionLinksDict["agent"] as! Int)
                    postLogin(apiToken: apiToken, agentId: agentId) {
                        completion(loginSucceeded: true)
                    }
                } else {
                    completion(loginSucceeded: false)
                }
            } else {
                completion(loginSucceeded: false)
            }
        }
    }
    
    // MARK: - Facebook login
    
    class func facebookLogin(accessToken: String, accessTokenExpiration: String, completion: (loginSucceeded: Bool) -> Void) {
        let parameters = [
            "access-token": accessToken,
            "access-token-expiration": accessTokenExpiration
        ]
        Alamofire.request(.POST, SITE_DOMAIN + "/facebook-login", parameters: parameters).responseJSON { response in
            if let JSON = response.result.value {
                if let sessionDict = JSON["session"] as? NSDictionary,
                       sessionLinksDict = sessionDict["links"] as? NSDictionary,
                       apiToken = sessionDict["id"] as? String {
                    let agentId = String(sessionLinksDict["agent"] as! Int)
                    postLogin(apiToken: apiToken, agentId: agentId) {
                        completion(loginSucceeded: true)
                    }
                } else {
                    completion(loginSucceeded: false)
                }
            } else {
                completion(loginSucceeded: false)
            }
        }
    }
    
    // MARK: - Post login (things to do on successfuly logging in)
    
    class func postLogin(apiToken apiToken: String, agentId: String, completion: (Void -> Void)?) {
        // initialize logged in agent and store agentId/apiToken
        let loggedInAgent = Agent()
        loggedInAgent.id = agentId
        loggedInAgent.apiToken = apiToken
        CacheManager.loggedInAgentId = agentId
        CacheManager.saveAgents([loggedInAgent])
        
        // update agent's device token on server
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let deviceToken = appDelegate.deviceToken {
            updateDeviceToken(deviceToken)
        }
        
        // get agent's info
        getAgentInfo(agentId) { agent in
            if let loggedInAgent = agent {
                loggedInAgent.apiToken = apiToken
                
                // cache logged in agent
                CacheManager.saveAgents([loggedInAgent])
                
                // get logged in agent's mate post
                getMate(agentId) { mate in
                    if let _mate = mate {
                        _mate.agent = loggedInAgent.copy() as! Agent
                        loggedInAgent.mate = _mate
                        
                        // update logged in agent in cache
                        CacheManager.saveAgents([loggedInAgent])
                    }
                    completion?()
                }
            }
        }
    }
    
    // MARK: - Update agent's device token on server
    
    class func updateDeviceToken(deviceToken: String) {
        guard let agentId = UserData.getLoggedInAgentId() else {
            return
        }
        
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "agents/\(agentId)")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "PUT"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "data": [
                "type": "agents",
                "id": agentId,
                "attributes": [
                    "device-token": deviceToken
                ]
            ]
        ]
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
        }
    }
    
    // MARK: - Get agent info
    
    class func getAgentInfo(agentId: String, completion: (agent: Agent?) -> Void) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "agents/\(agentId)?include=mate-posts")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            if let JSON = response.result.value {
                if let agentDict = JSON["data"] as? NSDictionary {
                    let agent = Agent(dict: agentDict)
                    completion(agent: agent)
                } else {
                    completion(agent: nil)
                }
            } else {
                completion(agent: nil)
            }
        }
    }
    
    // MARK: - Get mate
    
    class func getMate(agentId: String, completion: (mate: Mate?) -> Void) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "agents/\(agentId)/mate-posts")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            if let JSON = response.result.value {
                // mate
                if let matesArray = JSON["data"] as? NSArray {
                    if matesArray.count > 0 {
                        let mateDict = matesArray[0] as! NSDictionary
                        let mate = Mate(dict: mateDict)
                        
                        if let neighborhood = CacheManager.getNeighborhood(mate.neighborhoodId) {
                            mate.neighborhood = neighborhood
                        }
                        
                        completion(mate: mate)
                    } else {
                        completion(mate: nil)
                    }
                }
            } else {
                completion(mate: nil)
            }
        }
    }
    
    // MARK: - Get mates
    
    class func getMates(neighborhoodId neighborhoodId: String? = nil, completion: (mates: [Mate]) -> Void) {
        // add neighborhood filter if provided
        var neighborhoodFilter = ""
        if let nid = neighborhoodId {
            neighborhoodFilter = "&filter[neighborhood-id]=\(nid)"
        }
        
        let urlPart = "mates?filter[hidden]=false&filter[upcoming]=true\(neighborhoodFilter)&include=neighborhood,agent"
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + urlPart)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            var mates = [Mate]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    showNetworkingErrorAlert(response)
                    completion(mates: mates)
                    return
                }
                
                // neighborhoods, agents
                var neighborhoods = [String: Neighborhood]()
                var agents = [String: Agent]()
                if let includedArray = JSON["included"] as? NSArray {
                    for includedDict in (includedArray as? [NSDictionary])! {
                        let type = includedDict["type"] as! String
                        if type == "neighborhoods" {
                            let neighborhood = Neighborhood(dict: includedDict)
                            neighborhoods[neighborhood.id] = neighborhood
                        } else if type == "agents" {
                            let agent = Agent(dict: includedDict)
                            agents[agent.id] = agent
                        }
                    }
                }
                
                // mates
                if let matesArray = JSON["data"] as? NSArray {
                    for mateDict in (matesArray as? [NSDictionary])! {
                        let mate = Mate(dict: mateDict)
                        mate.neighborhood = neighborhoods[mate.neighborhoodId]
                        mate.agent = agents[mate.agentId]
                        mates.append(mate)
                    }
                }
                
                completion(mates: mates)
            } else {
                showNetworkingErrorAlert(response)
                completion(mates: mates)
            }
        }
    }
    
    // MARK: - Create mate
    
    class func createMate(mate: Mate, completion: (createMateSucceeded: Bool, errorMsg: String, createdMate: Mate?) -> Void) {
        // if we're updating, do a PUT to /mates/[id], otherwise, do a POST to /mates
        var httpMethod: String
        var URL: NSURL
        if mate.id != "" {
            httpMethod = "PUT"
            URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "mates/\(mate.id)")!
        } else {
            httpMethod = "POST"
            URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "mates")!
        }
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = httpMethod
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        var parameters = [
            "data": [
                "type": "mates",
                "attributes": [
                    "description": mate._description,
                    "price": mate.price,
                    "when": stringFromDate(mate.when),
                    "hidden": !mate.visible
                ],
                "relationships": [
                    "agent": [
                        "data": [
                            "id": mate.agentId,
                            "type": "agents"
                        ]
                    ],
                    "neighborhood": [
                        "data": [
                            "id": mate.neighborhoodId,
                            "type": "neighborhoods"
                        ]
                    ]
                ]
            ]
        ]
        
        // set id if we're updating
        if mate.id != "" {
            var data = parameters["data"]
            data!["id"] = mate.id
            parameters["data"] = data
        }
        
        // set image if it's new/changed
        if mate.image != "" {
            var data = parameters["data"]
            var attributes = data!["attributes"] as! [String: NSObject]
            attributes["image"] = "data:image/jpeg;base64,\(mate.image)"
            data!["attributes"] = attributes
            parameters["data"] = data
        }
        
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            if let JSON = response.result.value {
                if let errors = JSON["errors"] as? NSArray,
                    error = errors[0] as? NSDictionary {
                        var errorMsg = error["title"] as! String
                        // exception for clarifying the error message in the case of having already created a mate post
                        if errorMsg.rangeOfString("You can't post more than once.") != nil {
                            errorMsg = "You've already created a mate post."
                        } else if errorMsg.rangeOfString("Record not found") != nil {
                            errorMsg = "Unable to update a private post."
                        }
                        
                        completion(createMateSucceeded: false, errorMsg: errorMsg, createdMate: nil)
                } else {
                    // create mate object from json response
                    let createdMate = Mate(dict: JSON["data"] as! NSDictionary)
                    
                    // set neighborhood
                    if let neighborhood = CacheManager.getNeighborhood(createdMate.neighborhoodId) {
                        createdMate.neighborhood = neighborhood
                    }
                    
                    // set agent
                    if let agent = CacheManager.getAgent(createdMate.agentId) {
                        createdMate.agent = agent
                    }
                    
                    completion(createMateSucceeded: true, errorMsg: "", createdMate: createdMate)
                }
            } else {
                completion(createMateSucceeded: false, errorMsg: "", createdMate: nil)
            }
        }
    }
    
    // MARK: - Upload profile image
    
    class func uploadProfileImage(image: UIImage, completion: (uploadSucceeded: Bool, newThumbnailURL: String?) -> Void) {
        // make sure logged in
        guard let loggedInAgent = UserData.getLoggedInAgent() else {
            return
        }
        
        // get base64 string of image
        var base64String = ""
        var imageData: NSData
        if getImageFileSizeInMB(image) >= 3 {
            imageData = UIImageJPEGRepresentation(image, 0.70)!
        } else {
            imageData = UIImageJPEGRepresentation(image, 1)!
        }
        base64String = imageData.base64EncodedStringWithOptions([.Encoding64CharacterLineLength])
        
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "agents/\(loggedInAgent.id)")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "PUT"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "data": [
                "type": "agents",
                "id": loggedInAgent.id,
                "attributes": [
                    "profile-picture": "data:image/jpeg;base64,\(base64String)"
                ]
            ]
        ]
        
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            if let JSON = response.result.value {
                var newThumbnailURL: String?
                if let data = JSON["data"] as? NSDictionary, attributes = data["attributes"] as? NSDictionary {
                    newThumbnailURL = attributes["thumbnail"] as? String
                }
                
                if let _ = JSON["errors"] as? NSArray {
                    completion(uploadSucceeded: false, newThumbnailURL: nil)
                } else {
                    completion(uploadSucceeded: true, newThumbnailURL: newThumbnailURL)
                }
            } else {
                completion(uploadSucceeded: false, newThumbnailURL: nil)
            }
        }
    }
    
    // MARK: - Get listing favorites
    
    class func getListingFavorites(agentId agentId: String, completion: (listingFavorites: [ListingFavorite]) -> Void) {
        Alamofire.request(.GET, SITE_DOMAIN + API_PREFIX + "favorites?agent-id=\(agentId)&include=neighborhood,sales-agent").responseJSON { response in
            var listingFavorites = [ListingFavorite]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    showNetworkingErrorAlert(response)
                    completion(listingFavorites: listingFavorites)
                    return
                }
                
                // neighborhoods, agents
                var neighborhoods = [String: Neighborhood]()
                var agents = [String: Agent]()
                if let includedArray = JSON["included"] as? NSArray {
                    for includedDict in (includedArray as? [NSDictionary])! {
                        let type = includedDict["type"] as! String
                        if type == "neighborhoods" {
                            let neighborhood = Neighborhood(dict: includedDict)
                            neighborhoods[neighborhood.id] = neighborhood
                        } else if type == "agents" {
                            let agent = Agent(dict: includedDict)
                            agents[agent.id] = agent
                        }
                    }
                }
                
                // listing favorites
                if let listingFavoritesArray = JSON["data"] as? NSArray {
                    for listingFavoriteDict in (listingFavoritesArray as? [NSDictionary])! {
                        let listingFavorite = ListingFavorite(dict: listingFavoriteDict)
                        listingFavorite.neighborhood = neighborhoods[listingFavorite.neighborhoodId]
                        listingFavorite.agent = agents[listingFavorite.agentId]
                        
                        // don't include unavailable listings if getting non-logged in user's favorites
                        if !UserData.isLoggedInAgent(agentId: agentId) && !listingFavorite.available {
                        } else {
                            listingFavorites.append(listingFavorite)
                        }
                    }
                }
                
                completion(listingFavorites: listingFavorites)
            } else {
                showNetworkingErrorAlert(response)
                completion(listingFavorites: listingFavorites)
            }
        }
    }
    
    // MARK: - Get mate favorites
    
    class func getMateFavorites(agentId agentId: String, completion: (mateFavorites: [MateFavorite]) -> Void) {
        Alamofire.request(.GET, SITE_DOMAIN + API_PREFIX + "mate-favorites?agent-id=\(agentId)&filter[hidden]=false&include=neighborhood,agent").responseJSON { response in
            var mateFavorites = [MateFavorite]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    showNetworkingErrorAlert(response)
                    completion(mateFavorites: mateFavorites)
                    return
                }
                
                // neighborhoods, agents
                var neighborhoods = [String: Neighborhood]()
                var agents = [String: Agent]()
                if let includedArray = JSON["included"] as? NSArray {
                    for includedDict in (includedArray as? [NSDictionary])! {
                        let type = includedDict["type"] as! String
                        if type == "neighborhoods" {
                            let neighborhood = Neighborhood(dict: includedDict)
                            neighborhoods[neighborhood.id] = neighborhood
                        } else if type == "agents" {
                            let agent = Agent(dict: includedDict)
                            agents[agent.id] = agent
                        }
                    }
                }
                
                // mate favorites
                if let mateFavoritesArray = JSON["data"] as? NSArray {
                    for mateFavoriteDict in (mateFavoritesArray as? [NSDictionary])! {
                        let mateFavorite = MateFavorite(dict: mateFavoriteDict)
                        mateFavorite.neighborhood = neighborhoods[mateFavorite.neighborhoodId]
                        mateFavorite.agent = agents[mateFavorite.agentId]
                        mateFavorites.append(mateFavorite)
                    }
                }
                
                completion(mateFavorites: mateFavorites)
            } else {
                showNetworkingErrorAlert(response)
                completion(mateFavorites: mateFavorites)
            }
        }
    }
    
    // MARK: - Get location favorites
    
    class func getLocationFavorites(agentId agentId: String, completion: (locationFavorites: [LocationFavorite]) -> Void) {
        Alamofire.request(.GET, SITE_DOMAIN + API_PREFIX + "location-favorites?agent-id=\(agentId)").responseJSON { response in
            var locationFavorites = [LocationFavorite]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    showNetworkingErrorAlert(response)
                    completion(locationFavorites: locationFavorites)
                    return
                }
                
                // location favorites
                if let locationFavoritesArray = JSON["data"] as? NSArray {
                    for locationFavoriteDict in (locationFavoritesArray as? [NSDictionary])! {
                        let locationFavorite = LocationFavorite(dict: locationFavoriteDict)
                        locationFavorites.append(locationFavorite)
                    }
                }
                
                completion(locationFavorites: locationFavorites)
            } else {
                showNetworkingErrorAlert(response)
                completion(locationFavorites: locationFavorites)
            }
        }
    }
    
    // MARK: - Get listing ignores
    
    class func getListingIgnores(completion: (listingIgnores: [ListingIgnore]) -> Void) {
        // check if logged in
        if !UserData.isLoggedIn() {
            return
        }
        
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "ignored-listings")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            var listingIgnores = [ListingIgnore]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    showNetworkingErrorAlert(response)
                    completion(listingIgnores: listingIgnores)
                    return
                }
                
                // listing ignores
                if let listingIgnoresArray = JSON["data"] as? NSArray {
                    for listingIgnoreDict in (listingIgnoresArray as? [NSDictionary])! {
                        let listingIgnore = ListingIgnore(dict: listingIgnoreDict)
                        listingIgnores.append(listingIgnore)
                    }
                }
                
                completion(listingIgnores: listingIgnores)
            } else {
                showNetworkingErrorAlert(response)
                completion(listingIgnores: listingIgnores)
            }
        }
    }
    
    // MARK: - Get mate ignores
    
    class func getMateIgnores(completion: (mateIgnores: [MateIgnore]) -> Void) {
        // check if logged in
        if !UserData.isLoggedIn() {
            return
        }
        
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "mate-ignores")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            var mateIgnores = [MateIgnore]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    showNetworkingErrorAlert(response)
                    completion(mateIgnores: mateIgnores)
                    return
                }
                
                // mate ignores
                if let mateIgnoresArray = JSON["data"] as? NSArray {
                    for mateIgnoreDict in (mateIgnoresArray as? [NSDictionary])! {
                        let mateIgnore = MateIgnore(dict: mateIgnoreDict)
                        mateIgnores.append(mateIgnore)
                    }
                }
                
                completion(mateIgnores: mateIgnores)
            } else {
                showNetworkingErrorAlert(response)
                completion(mateIgnores: mateIgnores)
            }
        }
    }
    
    // MARK: - Favorite listing
    
    class func favoriteListing(listingId: String) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "hearts")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "data": [
                "type": "hearts",
                "attributes": [
                    "agent-id": UserData.getLoggedInAgentId()!,
                    "listing-id": listingId
                ]
            ]
        ]
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            guard let _ = response.result.value else {
                showNetworkingErrorAlert(response)
                return
            }
        }
    }
    
    // MARK: - Favorite mate
    
    class func favoriteMate(mateId: String) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "mate-post-likes")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "data": [
                "type": "mate-post-likes",
                "attributes": [
                    "agent-id": UserData.getLoggedInAgentId()!,
                    "mate-post-id": mateId
                ]
            ]
        ]
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            guard let _ = response.result.value else {
                showNetworkingErrorAlert(response)
                return
            }
        }
    }
    
    // MARK: - Favorite location
    
    class func favoriteLocation(locationId: String) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "location-likes")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "data": [
                "type": "location-likes",
                "attributes": [
                    "agent-id": UserData.getLoggedInAgentId()!,
                    "location-id": locationId
                ]
            ]
        ]
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            guard let _ = response.result.value else {
                showNetworkingErrorAlert(response)
                return
            }
        }
    }
    
    // MARK: - Ignore listing
    
    class func ignoreListing(listingId: String) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "listing-ignores")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "data": [
                "type": "listing-ignores",
                "attributes": [
                    "agent-id": UserData.getLoggedInAgentId()!,
                    "listing-id": listingId
                ]
            ]
        ]
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            guard let _ = response.result.value else {
                showNetworkingErrorAlert(response)
                return
            }
        }
    }
    
    // MARK: - Ignore mate
    
    class func ignoreMate(mateId: String) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "mate-post-ignores")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "data": [
                "type": "mate-post-ignores",
                "attributes": [
                    "agent-id": UserData.getLoggedInAgentId()!,
                    "mate-post-id": mateId
                ]
            ]
        ]
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            guard let _ = response.result.value else {
                showNetworkingErrorAlert(response)
                return
            }
        }
    }
    
    // MARK: - Unfavorite listing
    
    class func unfavoriteListing(listingId: String) {
        getHeartId(listingId) { heartId in
            if let heartIdToUse = heartId {
                let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "hearts/\(heartIdToUse)")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL)
                mutableURLRequest.HTTPMethod = "DELETE"
                mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
                
                Alamofire.request(mutableURLRequest).responseJSON { response in
                }
            }
        }
    }
    
    // MARK: Get heart id
    
    class func getHeartId(listingId: String, completion: (String? -> Void)?) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "hearts?filter[listing-id]=\(listingId)")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            if let JSON = response.result.value {
                var heartId: String?
                if let array = JSON["data"] as? NSArray {
                    if array.count > 0 {
                        heartId = array[0]["id"] as? String
                    }
                }
                completion?(heartId)
            } else {
                showNetworkingErrorAlert(response)
                completion?(nil)
            }
        }
    }
    
    // MARK: - Unfavorite mate
    
    class func unfavoriteMate(mateId: String) {
        getMatePostLikeId(mateId) { matePostLikeId in
            if let matePostLikeIdToUse = matePostLikeId {
                let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "mate-post-likes/\(matePostLikeIdToUse)")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL)
                mutableURLRequest.HTTPMethod = "DELETE"
                mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
                
                Alamofire.request(mutableURLRequest).responseJSON { response in
                }
            }
        }
    }
    
    // MARK: Get mate post like id
    
    class func getMatePostLikeId(mateId: String, completion: (String? -> Void)?) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "mate-post-likes?filter[mate-post-id]=\(mateId)")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            if let JSON = response.result.value {
                var matePostLikeId: String?
                if let array = JSON["data"] as? NSArray {
                    if array.count > 0 {
                        matePostLikeId = array[0]["id"] as? String
                    }
                }
                completion?(matePostLikeId)
            } else {
                showNetworkingErrorAlert(response)
                completion?(nil)
            }
        }
    }
    
    // MARK: - Unfavorite location
    
    class func unfavoriteLocation(locationId: String) {
        getLocationLikeId(locationId) { locationLikeId in
            if let locationLikeIdToUse = locationLikeId {
                let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "location-likes/\(locationLikeIdToUse)")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL)
                mutableURLRequest.HTTPMethod = "DELETE"
                mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
                
                Alamofire.request(mutableURLRequest).responseJSON { response in
                }
            }
        }
    }
    
    // MARK: Get location like id
    
    class func getLocationLikeId(locationId: String, completion: (String? -> Void)?) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "location-likes?filter[location-id]=\(locationId)")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            if let JSON = response.result.value {
                var locationLikeId: String?
                if let array = JSON["data"] as? NSArray {
                    if array.count > 0 {
                        locationLikeId = array[0]["id"] as? String
                    }
                }
                completion?(locationLikeId)
            } else {
                showNetworkingErrorAlert(response)
                completion?(nil)
            }
        }
    }
    
    // MARK: - Unignore listing
    
    class func unignoreListing(listing: Listing) {
        getListingIgnoreId(listing) { listingIgnoreId in
            if let listingIgnoreIdToUse = listingIgnoreId {
                let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "listing-ignores/\(listingIgnoreIdToUse)")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL)
                mutableURLRequest.HTTPMethod = "DELETE"
                mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
                
                Alamofire.request(mutableURLRequest).responseJSON { response in
                }
            }
        }
    }
    
    // MARK: Get listing ignore id
    
    class func getListingIgnoreId(listing: Listing, completion: (String? -> Void)?) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "listing-ignores?filter[listing-id]=\(listing.id)")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            if let JSON = response.result.value {
                var listingIgnoreId: String?
                if let array = JSON["data"] as? NSArray {
                    if array.count > 0 {
                        listingIgnoreId = array[0]["id"] as? String
                    }
                }
                completion?(listingIgnoreId)
            } else {
                showNetworkingErrorAlert(response)
                completion?(nil)
            }
        }
    }
    
    // MARK: - Unignore mate
    
    class func unignoreMate(mate: Mate) {
        getMatePostIgnoreId(mate) { matePostIgnoreId in
            if let matePostIgnoreIdToUse = matePostIgnoreId {
                let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "mate-post-ignores/\(matePostIgnoreIdToUse)")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL)
                mutableURLRequest.HTTPMethod = "DELETE"
                mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
                
                Alamofire.request(mutableURLRequest).responseJSON { response in
                }
            }
        }
    }
    
    // MARK: Get mate post ignore id
    
    class func getMatePostIgnoreId(mate: Mate, completion: (String? -> Void)?) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "mate-post-ignores?filter[mate-post-id]=\(mate.id)")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            if let JSON = response.result.value {
                var matePostIgnoreId: String?
                if let array = JSON["data"] as? NSArray {
                    if array.count > 0 {
                        matePostIgnoreId = array[0]["id"] as? String
                    }
                }
                completion?(matePostIgnoreId)
            } else {
                showNetworkingErrorAlert(response)
                completion?(nil)
            }
        }
    }
    
    // MARK: - Get conversations
    
    class func getConversations(completion: (conversations: [Conversation]) -> Void) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "conversations?include=participating-agents,messages")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            var conversations = [Conversation]()
            
            if let JSON = response.result.value {
                // check for errors
                if let _ = JSON["errors"] as? NSArray {
                    showNetworkingErrorAlert(response)
                    completion(conversations: conversations)
                    return
                }
                
                var _conversationDict = [String: Conversation]()
                var agentParticipantDict = [String: NSMutableArray]()
                var participants = [String: ConversationParticipant]()
                var agents = [String: Agent]()
                
                if let conversationsArray = JSON["data"] as? NSArray {
                    for conversationDict in (conversationsArray as? [NSDictionary])! {
                        // conversation
                        let conversation = Conversation(dict: conversationDict)
                        _conversationDict[conversation.id] = conversation
                        
                        // participants
                        if let attributes = conversationDict["attributes"] as? NSDictionary {
                            if let participantsArray = attributes["participants"] as? NSArray {
                                for participantDict in (participantsArray as? [NSDictionary])! {
                                    let participant = ConversationParticipant(dict: participantDict)
                                    participant.conversationId = conversation.id
                                    participants[participant.id] = participant
                                    
                                    /* 
                                     * Store agent-participant mapping so we can more easily associate
                                     * agent with participant when iterating over agents json.
                                     */
                                    let agentId = String(participantDict["agent_id"] as! Int)
                                    let participantId = String(participantDict["id"] as! Int)
                                    if let _ = agentParticipantDict[agentId] {
                                    } else {
                                        agentParticipantDict[agentId] = NSMutableArray()
                                    }
                                    agentParticipantDict[agentId]!.addObject(participantId)
                                }
                            }
                        }
                    }
                }
                
                // participating agents, messages
                if let includedArray = JSON["included"] as? NSArray {
                    for includedDict in (includedArray as? [NSDictionary])! {
                        let type = includedDict["type"] as! String
                        if type == "agents" {
                            let agentDict = includedDict
                            let agent = Agent(dict: agentDict)
                            agents[agent.id] = agent
                            
                            // associate agent with participant
                            for participantId in agentParticipantDict[agent.id]! {
                                let participantIdStr = participantId as! String
                                if let participant = participants[participantIdStr] {
                                    participant.agent = agent
                                    
                                    if let conversation = _conversationDict[participant.conversationId] {
                                        if UserData.isLoggedInAgent(agentId: participant.agent.id) {
                                            // flag conversation as archived/unarchived
                                            if participant.archived {
                                                conversation.archived = true
                                            }
                                            // flag conversation if it has unread messages
                                            if participant.hasUnreadMessages {
                                                conversation.hasUnreadMessages = true
                                            }
                                        }
                                        
                                        // add participant to conversation
                                        conversation.participants.append(participant)
                                        
                                        // update participants, conversations dictionary
                                        participants[participant.id] = participant
                                        _conversationDict[conversation.id] = conversation
                                    }
                                }
                            }
                        } else if type == "conversation-messages" {
                            if let relationships = includedDict["relationships"] as? NSDictionary {
                                if let conversation = relationships["conversation"] as? NSDictionary {
                                    if let conversationData = conversation["data"] as? NSDictionary {
                                        if let conversationId = conversationData["id"] as? String {
                                            let messageDict = includedDict
                                            let message = ConversationMessage(dict: messageDict)
                                            
                                            /* 
                                             * associate agent with message
                                             *
                                             * (NOTE: Ordering of the includes matters. We'll have already gotten
                                             *        all participants by the time we're parsing messages.)
                                             */
                                            if let agent = relationships["agent"] as? NSDictionary {
                                                if let agentData = agent["data"] as? NSDictionary {
                                                    if let agentId = agentData["id"] as? String {
                                                        message.agent = agents[agentId]
                                                    }
                                                }
                                            }
                                            
                                            // get conversation that message belongs to
                                            if let conversation = _conversationDict[conversationId] {
                                                message.conversationId = conversation.id
                                                
                                                // add message to conversation
                                                conversation.messages.append(message)
                                                
                                                // update conversations dictionary
                                                _conversationDict[conversation.id] = conversation
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // extract values from conversations dictionary
                conversations = Array(_conversationDict.values)
                
                completion(conversations: conversations)
            } else {
                showNetworkingErrorAlert(response)
                completion(conversations: conversations)
            }
        }
    }
    
    // MARK: - Create conversation [and participants]
    
    class func createConversation(conversation: Conversation, completion: (conversation: Conversation?) -> Void) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "conversations")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "data": [
                "type": "conversations",
                "attributes": [
                    "context-url": conversation.contextURL
                ]
            ]
        ]
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            if let JSON = response.result.value {
                if let dict = JSON["data"] as? NSDictionary {
                    let conversationId = dict["id"] as! String
                    print("new conversation id: \(conversationId)")
                    
                    // replace temp conversation object using new conversation id returned by api
                    let newConversation = conversation.copy() as! Conversation
                    newConversation.id = conversationId
                    
                    createParticipants(newConversation) {
                        completion(conversation: newConversation)
                    }
                } else {
                    completion(conversation: nil)
                }
            } else {
                showNetworkingErrorAlert(response)
                completion(conversation: nil)
            }
        }
    }
    
    // MARK: - Create participants
    
    class func createParticipants(conversation: Conversation, completion: (Void -> Void)?) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "conversation-participants")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        
        let tempParticipants = conversation.participants
        
        for tempParticipant in tempParticipants {
            let parameters = [
                "data": [
                    "type": "conversation-participants",
                    "relationships": [
                        "agent": [
                            "data": [
                                "id": tempParticipant.agent.id,
                                "type": "agents"
                            ]
                        ],
                        "conversation": [
                            "data": [
                                "id": conversation.id,
                                "type": "conversations"
                            ]
                        ]
                    ]
                ]
            ]
            do {
                mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
            } catch {
                // no-op
            }
            
            Alamofire.request(mutableURLRequest).responseJSON { response in
                if let JSON = response.result.value {
                    if let dict = JSON["data"] as? NSDictionary {
                        let participantId = dict["id"] as! String
                        
                        // create new participant object using new participant id returned by api
                        let newParticipant = tempParticipant.copy() as! ConversationParticipant
                        newParticipant.id = participantId
                        
                        // replace participant
                        if let oldParticipantIndex = conversation.participants.indexOf(tempParticipant) {
                            conversation.participants.replaceRange(oldParticipantIndex...oldParticipantIndex, with: [newParticipant])
                        }
                        
                        // only call completion handler after done with all temp participants
                        if tempParticipants[tempParticipants.count - 1] == tempParticipant {
                            completion?()
                        }
                    } else {
                        completion?()
                    }
                } else {
                    completion?()
                }
            }
        }
    }
    
    // MARK: - Send message
    
    class func sendMessage(conversation conversation: Conversation, message: ConversationMessage, completion: (Void -> Void)?) {
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "conversation-messages")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "data": [
                "type": "conversation-messages",
                "attributes": [
                    "message": message.message,
                    "ip-address": message.ipAddress,
                    "user-agent": message.userAgent
                ],
                "relationships": [
                    "agent": [
                        "data": [
                            "id": UserData.getLoggedInAgentId()!,
                            "type": "agents"
                        ]
                    ],
                    "conversation": [
                        "data": [
                            "id": message.conversationId,
                            "type": "conversations"
                        ]
                    ]
                ]
            ]
        ]
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
            if let JSON = response.result.value {
                if let dict = JSON["data"] as? NSDictionary {
                    // create new message from info returned by server
                    let newMessage = ConversationMessage(dict: dict)
                    
                    // replace message in conversation
                    if let oldMessageIndex = conversation.messages.indexOf(message) {
                        conversation.messages.replaceRange(oldMessageIndex...oldMessageIndex, with: [newMessage])
                    }
                }
                completion?()
            } else {
                showNetworkingErrorAlert(response)
                completion?()
            }
        }
    }
    
    // MARK: - Archive conversation
    
    class func archiveConversation(conversation: Conversation) {
        // get the conversation participant belonging to the logged in user
        var theParticipant: ConversationParticipant?
        for _participant in conversation.participants {
            if UserData.isLoggedInAgent(agentId: _participant.agent.id) {
                theParticipant = _participant
                break
            }
        }
        guard let participant = theParticipant else {
            return
        }
        
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "conversation-participants/\(participant.id)")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "PUT"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "data": [
                "id": participant.id,
                "attributes": [
                    "archived-at": stringFromDate(NSDate())
                ],
                "type": "conversation-participants"
            ]
        ]
        
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
        }
    }
    
    // MARK: - Unarchive conversation
    
    class func unarchiveConversation(conversation: Conversation) {
        // get the conversation participant belonging to the logged in user
        var theParticipant: ConversationParticipant?
        for _participant in conversation.participants {
            if UserData.isLoggedInAgent(agentId: _participant.agent.id) {
                theParticipant = _participant
                break
            }
        }
        guard let participant = theParticipant else {
            return
        }
        
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "conversation-participants/\(participant.id)")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "PUT"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "data": [
                "id": participant.id,
                "attributes": [
                    "archived-at": NSNull()
                ],
                "type": "conversation-participants"
            ]
        ]
        
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
        }
    }
    
    // MARK: - Mark conversation as read
    
    class func markConversationAsRead(conversation: Conversation) {
        // get the conversation participant belonging to the logged in user
        var theParticipant: ConversationParticipant?
        for _participant in conversation.participants {
            if UserData.isLoggedInAgent(agentId: _participant.agent.id) {
                theParticipant = _participant
                break
            }
        }
        guard let participant = theParticipant else {
            return
        }
        
        let URL = NSURL(string: SITE_DOMAIN + API_PREFIX + "conversation-participants/\(participant.id)")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "PUT"
        mutableURLRequest.setValue(UserData.getApiToken(), forHTTPHeaderField: "API-TOKEN")
        mutableURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "data": [
                "id": participant.id,
                "attributes": [
                    "unread-messages": false
                ],
                "type": "conversation-participants"
            ]
        ]
        
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        } catch {
            // no-op
        }
        
        Alamofire.request(mutableURLRequest).responseJSON { response in
        }
    }
}
