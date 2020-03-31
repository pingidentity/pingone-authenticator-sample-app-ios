//
//  ActiveUser.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit
import PingOne


struct User: Codable {
    let id: String
    var name: Name

    init(id: String, name: Name){
        self.id = id
        self.name = name
    }
}

struct Name: Codable {
    var given: String?
    var family: String?

    init(given: String?, family: String?){
        self.given = given ?? ""
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





