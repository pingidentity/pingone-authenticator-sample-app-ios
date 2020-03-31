//
//  Defaults.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import Foundation

class Defaults{
    class func defaults() -> UserDefaults{
        return UserDefaults.standard
    }
    
    class func getNotificationPermissionCounter() -> Int {
        return defaults().integer(forKey: DefaultsKeys.notificationPermissionCounter)
    }
    
    class func increaseNotificationPermissionCounter() {
        let counter = Defaults.getNotificationPermissionCounter() + 1
        defaults().set(counter, forKey: DefaultsKeys.notificationPermissionCounter)
    }
    
    class func isPaired() -> Bool {
        return defaults().bool(forKey: DefaultsKeys.isPairedKey)
    }
    
    class func setPaired(isPaired: Bool) {
        defaults().set(isPaired, forKey: DefaultsKeys.isPairedKey)
    }
    
    class func addedUserReset() {
        defaults().set(false, forKey: DefaultsKeys.isUserAdded)
    }
    
    class func addedNewUser() {
        defaults().set(true, forKey: DefaultsKeys.isUserAdded)
    }
    
    class func isNewUserAdded() -> Bool {
        return defaults().bool(forKey: DefaultsKeys.isUserAdded)
    }
    
    class func setSupportID(idStr: String) {
        defaults().set(idStr, forKey: DefaultsKeys.supportID)
    }
    
    class func getSupportID() -> String {
        return defaults().value(forKey: DefaultsKeys.supportID) as? String ?? ""
    }
    
    class func setUserData(id: String, name: String) {
        var usersDict = getUsersData()
        usersDict[id] = name
        defaults().set(usersDict, forKey: DefaultsKeys.usersDefaultKey)
    }
    
    class func getUsersData() -> [String : String] {
        return defaults().object(forKey: DefaultsKeys.usersDefaultKey) as? [String : String] ?? [:]
    }
        
    class func sync() {
        defaults().synchronize()
    }
}
