//
//  ActiveUser.swift
//  Authenticator
//
//  Created by Amit Nadir on 11/02/2020.
//  Copyright © 2020 Ping Identity. All rights reserved.
//

import UIKit
import PingOne


struct User: Codable {
    let id: String
    let name: Name

    init(id: String, name: Name){
        self.id = id
        self.name = name
    }
}

struct Name: Codable {
    let given: String?
    let family: String?

    init(given: String?, family: String?){
        self.given = given ?? "User"
        self.family = family ?? ""
    }
}

@objc public class ActiveUser: NSObject{
    
    func setUserData(data: [String:Any]) -> [User]?{
        var usersArray = [User]()
        let users = data["users"] as? [[String:Any]] ?? [[:]]
        
        for user in users {
            let parsedUser = parseUser(userDict: user)
            usersArray.append(parsedUser)
        }
        return usersArray
    }
    
    func parseUser(userDict: [String:Any]) -> User {
        let nameDict = userDict["name"] as? [String:Any] ?? [:]
        let id = userDict["id"] as? String ?? ""
        let name = Name.init(given: nameDict["given"] as? String ?? "", family: nameDict["family"] as? String ?? "")
        let user = User.init(id: id, name: name)
        return user
    }
}





