//
//  UserData.swift
//  Nooklyn
//
//  Created by Joe Gallo on 10/19/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

import UIKit

class UserData {
    
    // MARK: - Check if logged in

    class func isLoggedIn() -> Bool {
        if let _ = CacheManager.loggedInAgentId {
            return true
        }
        return false
    }

    // MARK: - Logged in agent id

    class func getLoggedInAgentId() -> String? {
        return CacheManager.loggedInAgentId
    }

    // MARK: - Logged in agent

    class func isLoggedInAgent(agentId agentId: String) -> Bool {
        return agentId == getLoggedInAgentId()
    }
    
    class func getLoggedInAgent() -> Agent? {
        guard let _loggedInAgentId = getLoggedInAgentId() else {
            return nil
        }
        return CacheManager.getAgent(_loggedInAgentId)
    }

    // MARK: - Facebook authenticated

    class func isFacebookAuthenticated() -> Bool {
        guard let _loggedInAgentId = getLoggedInAgentId(), loggedInAgent = CacheManager.getAgent(_loggedInAgentId) else {
            return false
        }
        return loggedInAgent.facebookAuthenticated
    }
    
    // MARK: - Logged in agent is employee
    
    class func loggedInAgentIsEmployee() -> Bool {
        guard let _loggedInAgentId = getLoggedInAgentId(), loggedInAgent = CacheManager.getAgent(_loggedInAgentId) else {
            return false
        }
        return loggedInAgent.employee
    }
    
    // MARK: - Api token
    
    class func getApiToken() -> String? {
        guard let _loggedInAgentId = getLoggedInAgentId(), loggedInAgent = CacheManager.getAgent(_loggedInAgentId) else {
            return nil
        }
        return loggedInAgent.apiToken
    }
}
