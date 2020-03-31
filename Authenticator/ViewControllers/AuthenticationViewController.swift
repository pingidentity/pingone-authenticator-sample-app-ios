//
//  AuthenticationViewController.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit
import LocalAuthentication
import PingOne

class AuthenticationViewController: MainViewController {
    
    @IBOutlet weak var approveDenyStackView: UIStackView!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var denyBtn: UIButton!
    
    var notificationObject: NotificationObject?
    private var isBiomertics = true
    private let context = LAContext()
    private var timer: Timer!
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }

    var biometricType: BiometricType {
        get {
            let context = LAContext()
            var error: NSError?

            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                print(error?.localizedDescription ?? "")
                return .none
            }

            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .none:
                    return .none
                case .touchID:
                    return .touchID
                case .faceID:
                    return .faceID
                @unknown default:
                    fatalError()
                }
            } else {
                return  .touchID
            }
        }
    }
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.navigationController == nil {
            let navBar: NavBar = UIView.fromNib()
            navBar.sideMenuBtn.isHidden = true
            self.view.addSubview(navBar)
        }
        approveDenyStackView.isHidden = true
        approveBtn.setTitle("approve_button".localized, for: .normal)
        denyBtn.setTitle("deny_button".localized, for: .normal)
        
        startTimeoutCount()
        authenticateStart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.timer.invalidate()
        self.context.invalidate()
    }
    
    //MARK: Authentication methods
    
    @IBAction func approve(_ sender: UIButton) {
        self.startLoadingAnimation()
        approvalProcess()
    }
    
    @IBAction func deny(_ sender: UIButton) {
        self.startLoadingAnimation()
        denyProcess()
    }
    
    func approvalProcess(){
        resetAppNotification()
        guard let notificationObject = notificationObject else {
            self.stopLoadingAnimation()
        return }
        
        notificationObject.approve(withAuthenticationMethod: DefaultsKeys.notificationMethodType) { (error) in
            DispatchQueue.main.async {
                if let error = error{
                    if error.code == ServerErrors.timeoutError {
                        self.moveToStatusVC(status: .timeout)
                    } else {
                        self.moveToStatusVC(status: .failure)
                    }
                }
                else{
                    self.moveToStatusVC(status: .success)
                }
            }
        }
    }
    
    func denyProcess(){
        if !timer.isValid { return }
        resetAppNotification()
        guard let notificationObject = notificationObject else {
            self.stopLoadingAnimation()
        return }
        
        notificationObject.deny { (error) in
            DispatchQueue.main.async {
                self.moveToStatusVC(status: .failure)
            }
        }
    }
    
    func startTimeoutCount(){
        guard let notificationObject = notificationObject else {
            self.stopLoadingAnimation()
        return }
        let duartion = Double(notificationObject.timeoutDuration)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: duartion, repeats: true) { timer in
            timer.invalidate()
            self.authTimeout()
        }
    }
    
    func authTimeout(){
        DispatchQueue.main.async {
            self.resetAppNotification()
            self.timer.invalidate()
            self.context.invalidate()
            self.moveToStatusVC(status: .timeout)
        }
    }
    
    func resetAppNotification(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error accessing AppDelegate")
            return
        }
        appDelegate.notificationObject = nil
    }
    
    func moveToStatusVC(status: authStatus){
        self.timer.invalidate()
        
        if let story = self.storyboard{
            if let statusVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.StatusVcID) as? StatusViewController {
                statusVc.isAuth = true
                statusVc.authStatus = status
                statusVc.modalTransitionStyle = .crossDissolve
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    print("Error accessing AppDelegate")
                    return
                }

                appDelegate.containerVc?.present(statusVc, animated: true) {
                    self.dismiss(animated: false, completion: nil)
                    self.stopLoadingAnimation()
                }
            }
        }
    }
    
    //MARK: Biometrics logic
    
    func authenticateStart() {
        if biometricType == BiometricType.faceID {
            let ac = UIAlertController(title: "faceid_consent_title".localized, message: "faceid_consent_msg".localized, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok".localized, style: .default, handler: { (action) in
                self.startBiometricsAuth(policy: .deviceOwnerAuthentication)
            })
            ac.addAction(okAction)
            
            self.present(ac, animated: true)
        } else {
            self.startBiometricsAuth(policy: .deviceOwnerAuthentication)
        }
    }
        
    func startBiometricsAuth(policy: LAPolicy) {
        var error: NSError?

        if context.canEvaluatePolicy(policy, error: &error) {
            let reason = "identify_with_biometrics_msg".localized
            
            context.evaluatePolicy(policy, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    self?.startLoadingAnimation()

                    if (authenticationError != nil) { //User failed biometrices login
                    
                        if let error = authenticationError as? LAError {
                            let errorCode = Int32(error.errorCode)
                            
                            if errorCode == kLAErrorUserFallback {
                                self?.startBiometricsAuth(policy: .deviceOwnerAuthentication)
                            }
                            else if errorCode == kLAErrorPasscodeNotSet {
                                self?.approveDenyStackView.isHidden = false
                                self?.isBiomertics = false
                            }
                            else {
                                self?.denyProcess()
                            }
                        }
                    }
                    else {
                        if success {
                            self?.approvalProcess()
                        }
                        else {
                            if let timerValid = self?.timer.isValid {
                                if timerValid {
                                    self?.denyProcess()
                                } else {
                                    self?.authTimeout()
                                }
                            }
                        }
                    }
                }
            }
            
        } else {
            //Biometrics not registered, Approve or Deny with buttons on screen
            approveDenyStackView.isHidden = false
            isBiomertics = false
        }
    }
}

