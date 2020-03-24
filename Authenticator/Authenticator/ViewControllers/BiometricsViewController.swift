//
//  BiometricsViewController.swift
//  Authenticator
//
//  Created by Amit Nadir on 05/02/2020.
//  Copyright © 2020 Ping Identity. All rights reserved.
//

import UIKit
import LocalAuthentication

class BiometricsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateStart()
    }
    

    func authenticateStart() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        if let navigation = self?.navigationController, let story = self?.storyboard{
                            let vc = story.instantiateViewController(withIdentifier: "UsersVcID")
                            navigation.pushViewController(vc, animated: false)
                        }
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        let tryAaginAction = UIAlertAction(title: "Try Again", style: .default, handler: { (action) in
                             self?.authenticateStart()
                        })
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        ac.addAction(tryAaginAction)
                        
                        self?.present(ac, animated: true)
                    }
                }               
            }
            
        } else {
            //Not registered to Biometrics
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }

}
