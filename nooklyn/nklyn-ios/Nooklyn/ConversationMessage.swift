//
//  ConversationMessage.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/2/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

class ConversationMessage: NSObject, NSCoding, NSCopying {
    var id = ""
    var message = ""
    var ipAddress = ""
    var userAgent = ""
    var createdAt = NSDate()
    var updatedAt = NSDate()
    var conversationId = ""
    var agentId = ""
    var agent: Agent!
    
    override init() {
        super.init()
    }
    
    init(dict: NSDictionary) {
        if let id = dict["id"] as? String { self.id = id }
        
        if let attributes = dict["attributes"] as? NSDictionary {
            if let message = attributes["message"] as? String { self.message = message }
            if let ipAddress = attributes["ip-address"] as? String { self.ipAddress = ipAddress }
            if let userAgent = attributes["user-agent"] as? String { self.userAgent = userAgent }
            if let createdAt = attributes["created-at"] as? String { self.createdAt = dateFromString(createdAt) ?? NSDate() }
            if let updatedAt = attributes["updated-at"] as? String { self.updatedAt = dateFromString(updatedAt) ?? NSDate() }
        }
        
        if let relationships = dict["relationships"] as? NSDictionary {
            // conversation
            if let conversationDict = relationships["conversation"] as? NSDictionary {
                if let conversationData = conversationDict["data"] as? NSDictionary {
                    if let conversationId = conversationData["id"] as? String {
                        self.conversationId = conversationId
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
        if let message = decoder.decodeObjectForKey("message") as? String { self.message = message }
        if let ipAddress = decoder.decodeObjectForKey("ipAddress") as? String { self.ipAddress = ipAddress }
        if let userAgent = decoder.decodeObjectForKey("userAgent") as? String { self.userAgent = userAgent }
        if let createdAt = decoder.decodeObjectForKey("createdAt") as? NSDate { self.createdAt = createdAt }
        if let updatedAt = decoder.decodeObjectForKey("updatedAt") as? NSDate { self.updatedAt = updatedAt }
        if let conversationId = decoder.decodeObjectForKey("conversationId") as? String { self.conversationId = conversationId }
        if let agentId = decoder.decodeObjectForKey("agentId") as? String { self.agentId = agentId }
        if let agent = decoder.decodeObjectForKey("agent") as? Agent { self.agent = agent }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.message, forKey: "message")
        coder.encodeObject(self.ipAddress, forKey: "ipAddress")
        coder.encodeObject(self.userAgent, forKey: "userAgent")
        coder.encodeObject(self.createdAt, forKey: "createdAt")
        coder.encodeObject(self.updatedAt, forKey: "updatedAt")
        coder.encodeObject(self.conversationId, forKey: "conversationId")
        coder.encodeObject(self.agentId, forKey: "agentId")
        coder.encodeObject(self.agent, forKey: "agent")
    }
    
    // MARK: - NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = ConversationMessage()
        copy.id = id
        copy.message = message
        copy.ipAddress = ipAddress
        copy.userAgent = userAgent
        copy.createdAt = createdAt
        copy.updatedAt = updatedAt
        copy.conversationId = conversationId
        copy.agentId = agentId
        copy.agent = agent
        return copy
    }
    
    // MARK: - Properties
    
    var formattedUpdatedAtDate: String! {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY"
        return stringFromDate(updatedAt, dateFormatter: dateFormatter)
    }
    
    var formattedUpdatedAtTime: String! {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm a"
        return stringFromDate(updatedAt, dateFormatter: dateFormatter)
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? ConversationMessage {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: ConversationMessage, rhs: ConversationMessage) -> Bool {
    return lhs.id == rhs.id
}
