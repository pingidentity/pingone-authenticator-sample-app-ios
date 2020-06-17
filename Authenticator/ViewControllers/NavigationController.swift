//
//  NavigationController.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit
import PingOne

class NavigationController: UINavigationController {

    let navBar: NavBar = UIView.fromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(navBar)
        
        routeViewControllers()
    }
    
    func routeViewControllers(){
        
        if let story = self.storyboard{
            let vc :UIViewController
            self.navBar.sideMenuBtn.isHidden = true
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("Error accessing AppDelegate")
                return
            }
            appDelegate.navigationVc = self
            
            if Defaults.isPaired(){
                self.navBar.sideMenuBtn.isHidden = false
                vc = story.instantiateViewController(withIdentifier: ViewControllerKeys.UsersVcID)
            }
            else{
                if Defaults.getNotificationPermissionCounter() == 0 {
                    vc = story.instantiateViewController(withIdentifier: ViewControllerKeys.NotificationVcID)
                }
                else{
                    self.navBar.layer.applySketchShadow(color: .darkGray)
                    vc = story.instantiateViewController(withIdentifier: ViewControllerKeys.PairVcID)
                }
            }
            self.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationBar.barTintColor = .white
        self.navigationBar.isTranslucent = false
    }
}
