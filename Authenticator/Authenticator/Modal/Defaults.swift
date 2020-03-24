//
//  Defaults.swift
//  SampleApp
//
//  Created by Segev Sherry on 3/26/19.
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
    

    /*class func setIssuer(_ issuer: String) {
        defaults().set(issuer, forKey: DefaultsKey.Issuer)
    }
    class func getIssuer() -> String? {
        if let issuer = defaults().string(forKey: DefaultsKey.Issuer){
            return issuer
        }
        return nil
    }*/

    
    class func sync() {
        defaults().synchronize()
    }
}
