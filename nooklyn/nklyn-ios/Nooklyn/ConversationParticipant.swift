//
//  ConversationParticipant.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/2/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

class ConversationParticipant: NSObject, NSCoding, NSCopying {
    var id = ""
    var archivedAt: NSDate? = nil
    var hasUnreadMessages = false
    var agent: Agent!
    var conversationId = ""
    
    override init() {
        super.init()
    }
    
    init(dict: NSDictionary) {
        if let id = dict["id"] as? Int { self.id = String(id) }
        if let archivedAt = dict["archived_at"] as? String { self.archivedAt = dateFromString(archivedAt) }
        if let hasUnreadMessages = dict["unread_messages"] as? Bool { self.hasUnreadMessages = hasUnreadMessages }
    }
    
    // MARK: - NSCopying
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = ConversationParticipant()
        copy.id = id
        copy.archivedAt = archivedAt
        copy.hasUnreadMessages = hasUnreadMessages
        copy.agent = agent
        copy.conversationId = conversationId
        return copy
    }
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        if let id = decoder.decodeObjectForKey("id") as? String { self.id = id }
        if let archivedAt = decoder.decodeObjectForKey("archivedAt") as? NSDate { self.archivedAt = archivedAt }
        self.hasUnreadMessages = decoder.decodeBoolForKey("hasUnreadMessages")
        if let agent = decoder.decodeObjectForKey("agent") as? Agent { self.agent = agent }
        if let conversationId = decoder.decodeObjectForKey("conversationId") as? String { self.conversationId = conversationId }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.archivedAt, forKey: "archivedAt")
        coder.encodeBool(self.hasUnreadMessages, forKey: "hasUnreadMessages")
        coder.encodeObject(self.agent, forKey: "agent")
        coder.encodeObject(self.conversationId, forKey: "conversationId")
    }
    
    // MARK: - Properties
    
    var archived: Bool {
        if let _ = archivedAt {
            return true
        }
        return false
    }
    
    // MARK: - Compare
    
    override func isEqual(other: AnyObject?) -> Bool {
        if let other = other as? ConversationParticipant {
            return id == other.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

func ==(lhs: ConversationParticipant, rhs: ConversationParticipant) -> Bool {
    return lhs.id == rhs.id
}
