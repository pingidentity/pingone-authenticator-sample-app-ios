//
//  AuthUserHandler.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import Foundation

class AuthUserHandler {
    
    func createUsersArray(_ users: [[String: Any]]) -> [User] {
        var usersArray = [User]()
        for user in users {
            guard let usersData = try? JSONSerialization.data(withJSONObject: user, options: []) else {
                continue
            }
            guard let userResponse = try? JSONDecoder().decode(User.self, from: usersData) else {
                continue
            }
            let userId = userResponse.id
            let given = userResponse.name.given
            let family = userResponse.name.family
            let username = userResponse.username
            let newUser = User.init(id: userId, name: Name.init(given: given, family: family), username: username)
            
            usersArray.append(newUser)
        }
        usersArray = updateEditedUsers(users: usersArray)
        return usersArray
    }
    
    func updateEditedUsers(users: [User]) -> [User] {
        var usersSynchedArray = [User]()
        let usersDictStorage = Defaults.getUsersData()
        for user in users {
            var userUpdated = user
            
            if let userName = usersDictStorage[user.id], (usersDictStorage[user.id]?.count ?? 0) > 0 {
                userUpdated.name.given = userName
                userUpdated.name.family = ""
            }
            usersSynchedArray.append(userUpdated)
        }
        return usersSynchedArray
    }
}
