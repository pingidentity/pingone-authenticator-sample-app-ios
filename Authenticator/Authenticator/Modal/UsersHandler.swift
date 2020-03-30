//
//  usersHandler.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit

class UsersHandler: NSObject {
    
    func getSynchedUsers(_ usersFromServer: [User]) -> [User] {
        var usersSynchedArray = [User]()
        let usersDictStorage = Defaults.getUsersData()
        
        for user in usersFromServer {
            var userUpdated = user
            
            if let userName = usersDictStorage[user.id], (usersDictStorage[user.id]?.count ?? 0) > 0  {
                userUpdated.name.given = userName
                userUpdated.name.family = ""
            }
            
            usersSynchedArray.append(userUpdated)
        }
        
        return usersSynchedArray
    }
    
    func isNewUserAdded() -> Bool {
        return Defaults.isNewUserAdded()
    }
    
    func addedUserReset() {
        return Defaults.addedUserReset()
    }
    
    func getUserByID(users: [User], userID: String) -> User? {
        for user in users {
            if user.id == userID {
                return user
            }
        }
        return nil
    }
    
}
