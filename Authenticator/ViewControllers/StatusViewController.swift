//
//  StatusViewController.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit
import PingOneSDK

enum authStatus {
    case success
    case failure
    case timeout
    case deny
    case completed
}

class StatusViewController: MainViewController {
    
    @IBOutlet weak var spinnerImageView: UIImageView!
    @IBOutlet weak var statusBackgroundView: UIView!
    @IBOutlet weak var statusMessage: UILabel!
    var isAuth = false
    var isPairing = false
    var isAuthQRCode = false
    var authStatus: authStatus?
    var color: UIColor?
    var message: String?
    
    // QR code data
    var authObject: AuthenticationObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isAuth {
            self.statusBackgroundView.backgroundColor = .customBlueVerify
            spinnerImageView.rotate()
            statusMessage.text = "verifying".localized
        } else if isAuth == true {
            setAuthMsg()
            switch self.authStatus {
            case .success, .completed:
                success()
            case .failure:
                failure()
            case .timeout:
                timeout()
            case .none, .deny:
                failure()
            } 
        }
    }
    
    func setAuthMsg() {
        statusMessage.text = self.message
    }
    
    func showAuth() {
        self.view.setNeedsLayout()
        var imageName: String
        
        switch self.authStatus {
        case .success:
            imageName = "icon_checkmark"
            if isAuth || isAuthQRCode {
                message = "approved".localized
            } else if isPairing {
                message = "paired".localized
            }
            statusBackgroundView.backgroundColor = .customGreen
            
        case .failure:
            imageName = "icon_invalid"
            if message == nil {
                message = "blocked".localized
            }
            
            if !isPairing && !isAuthQRCode {
                message = "error".localized
            }
            
            statusBackgroundView.backgroundColor = .customRed
            
        case .timeout:
            imageName = "icon_timeout"
            message = "timeout".localized
            statusBackgroundView.backgroundColor = .customYellow
        
        case .deny:
            imageName = "icon_invalid"
            message = "denied".localized
            
            statusBackgroundView.backgroundColor = .customRed
        
        case .completed:
            imageName = "icon_invalid"
            message = "completed".localized
            
            statusBackgroundView.backgroundColor = .customGreen
            
        case .none:
            imageName = "icon_invalid"
            message = "blocked".localized
            statusBackgroundView.backgroundColor = .customRed
        }
        
        self.spinnerImageView.image = UIImage.init(named: imageName)
    }
    
    func success() {
        showAuth()
        setAuthMsg()
        self.spinnerImageView.layer.removeAllAnimations()
        self.dismissSelf()
    }
    
    func continueToUsersSelection() {
        self.dismissSelf()
    }
    
    func timeout() {
        showAuth()
        setAuthMsg()
        self.spinnerImageView.layer.removeAllAnimations()
        self.dismissSelf()
    }
    
    func failure() {
        showAuth()
        setAuthMsg()
        self.spinnerImageView.layer.removeAllAnimations()
        self.dismissSelf()
    }
    
    func denied() {
        showAuth()
        setAuthMsg()
        self.spinnerImageView.layer.removeAllAnimations()
        self.dismissSelf()
    }
    
    func dismissSelf() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.dismiss(animated: true, completion: {
                self.spinnerImageView.layer.removeAllAnimations()
            })
        }
    }
}
