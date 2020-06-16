//
//  StatusViewController.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit

enum authStatus {
    case success
    case failure
    case timeout
}

class StatusViewController: MainViewController {
    
    @IBOutlet weak var spinnerImageView: UIImageView!
    @IBOutlet weak var statusBackgroundView: UIView!
    @IBOutlet weak var statusMessage: UILabel!
    var isAuth: Bool!
    var authStatus: authStatus!
    var color: UIColor?
    var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.isAuth == nil || !self.isAuth) {
            self.statusBackgroundView.backgroundColor = .customBlueVerify
            spinnerImageView.rotate()
            statusMessage.text = "verifying".localized
        }
        else if self.isAuth == true{
            setAuthMsg()
            switch self.authStatus {
            case .success:
                success()
            case .failure:
                failure()
            case .timeout:
                timeout()
            case .none:
                failure()
            } 
        }
    }
    
    func setAuthMsg(){
        statusMessage.text = self.message
    }
    
    func showAuth(){
        self.view.setNeedsLayout()
        var imageName: String
        
        switch self.authStatus {
        case .success:
            imageName = "icon_checkmark"
            message = self.isAuth ? "approved".localized : "paired".localized
            statusBackgroundView.backgroundColor = .customGreen
            
        case .failure:
            imageName = "icon_invalid"
            if message == nil {
                message = "blocked".localized
            }
            statusBackgroundView.backgroundColor = .customRed
            
        case .timeout:
            imageName = "icon_timeout"
            message = "timeout".localized
            statusBackgroundView.backgroundColor = .customYellow
            
        case .none:
            imageName = "icon_invalid"
            message = "blocked".localized
            statusBackgroundView.backgroundColor = .customRed
        }
        
        self.spinnerImageView.image = UIImage.init(named: imageName)
    }
    
    func success(){
        showAuth()
        setAuthMsg()
        self.spinnerImageView.layer.removeAllAnimations()
        self.dismissSelf()
    }
    
    func timeout(){
        showAuth()
        setAuthMsg()
        self.spinnerImageView.layer.removeAllAnimations()
        self.dismissSelf()
    }
    
    func failure(){
        showAuth()
        setAuthMsg()
        self.spinnerImageView.layer.removeAllAnimations()
        self.dismissSelf()
    }
    
    func dismissSelf(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            self.dismiss(animated: true, completion: nil)
        }
    }
}
