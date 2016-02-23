//
//  Conversation.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/2/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

class Conversation: NSObject, NSCoding, NSCopying {
    var id = ""
    var createdAt = NSDate()
    var updatedAt = NSDate()
    var contextURL = ""
    var messagesURL = ""
    var archived = false
    var hasUnreadMessages = false
    var participants = [ConversationParticipant]()
    var messages = [ConversationMessage]()
    
    override init() {
        super.init()
    }
    
    init(dict: NSDictionary) {
        if let id = dict["id"] as? String { self.id = id }
        
        if let attributes = dict["attributes"] as? NSDictionary {
            if let createdAt = attributes["created-at"] as? String { self.createdAt = dateFromString(createdAt) ?? NSDate() }
            if let updatedAt = attributes["updated-at"] as? String { self.updatedAt = dateFromString(updatedAt) ?? NSDate() }
            if let contextURL = attributes["context-url"] as? String { self.contextURL = contextURL }
        }
        
        if let relationships = dict["relationships"] as? NSDictionary {
            if let messages = relationships["messages"] as? NSDictionary {
                if let links = messages["links"] as? NSDictionary {
                    if let messagesURL = links["related"] as? String { self.messagesURL = messagesURL }
                }
            }
        }
    }
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        if let id = decoder.decodeObjectForKey("id") as? String { self.id = id }
        if let createdAt = decoder.decodeObjectForKey("createdAt") as? NSDate { self.createdAt = createdAt }
        if let updatedAt = decoder.decodeObjectForKey("updatedAt") as? NSDate { self.updatedAt = updatedAt }
        if let contextURL = decoder.decodeObjectForKey("contextURL") as? String { self.contextURL = contextURL }
        if let messagesURL = decoder.decodeObjectForKey("messagesURL") as? String { self.messagesURL = messagesURL }
        self.archived = decoder.decodeBoolForKey("archived")
        self.hasUnreadMessages = decoder.decodeBoolForKey("hasUnreadMessages")
        if let participants = decoder.decodeObjectForKey("participants") as? [ConversationParticipant] { self.participants = participants }
        if let messages = decoder.decodeObjectForKey("messages") as? [ConversationMessage] { self.messages = messages }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.createdAt, forKey: "createdAt")
        coder.encodeObject(self.updatedAt, forKey: "updatedAt")
        coder.encodeObject(self.contextURL, forKey: "contextURL")
        coder.encodeObject(self.messagesURL, forKey: "messagesURL")
        coder.encodeBool(self.archived, forKey: "archived")
        coder.encodeBool(self.hasUnreadMessages, forKey: "hasUnreadMessages")
        coder.encodeObject(self.participants, forKey: "participants")
        coder.encodeObject(self.messages, forKey: "messages")
    }
    
    // MARK: - NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Conversation()
        copy.id = id
        copy.createdAt = createdAt
        copy.updatedAt = updatedAt
        copy.contextURL = contextURL
        copy.messagesURL = messagesURL
        copy.archived = archived
        copy.hasUnreadMessages = hasUnreadMessages
        copy.participants = participants
        copy.messages = messages
        return copy
    }
    
    // MARK: - Properties
    
    var formattedUpdatedAt: String! {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY"
        return stringFromDate(updatedAt, dateFormatter: dateFormatter)
    }
    
    var otherParticipants: [ConversationParticipant] {
        var otherParticipants = [ConversationParticipant]()
        
        for participant in participants {
            if participant.agent?.id != UserData.getLoggedInAgentId() {
                otherParticipants.append(participant)
            }
        }
        
        return otherParticipants
    }
    
    var otherParticipantNames: String {
        let shortNames = otherParticipants.map({ $0.agent?.shortName ?? "??" })
        return shortNames.joinWithSeparator(", ")
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? Conversation {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.id == rhs.id
}
