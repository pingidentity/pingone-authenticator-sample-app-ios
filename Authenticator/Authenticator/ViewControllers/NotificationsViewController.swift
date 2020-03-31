//
//  NotificationsViewController.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit

class NotificationsViewController: MainViewController {

    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var vcBody: UITextView!
    @IBOutlet weak var enableBtnOutlt: UIButton!
    @IBAction func enableBtnAction(_ sender: UIButton) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error accessing AppDelegate")
            return
        }
        appDelegate.registerRemoteNotifications {
            Defaults.increaseNotificationPermissionCounter()
            DispatchQueue.main.async{
                if let navigation = self.navigationController as? NavigationController, let story = self.storyboard{
                    let vc = story.instantiateViewController(withIdentifier: ViewControllerKeys.PairVcID) as! PairViewController
                    navigation.pushViewController(vc, animated: true)
                }
            }
        }        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreenTexts()
    }
    
    func setupScreenTexts(){
        vcTitle.text = "notification_title".localized
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String ?? "defualt_app_name".localized
        vcBody.text = "\(appName) \("notification_body".localized)"
        enableBtnOutlt.setTitle("notification_confirm_button".localized, for: .normal)
    }
}
