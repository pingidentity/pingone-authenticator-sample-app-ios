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
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var notificationBody: UILabel!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var denyBtn: UIButton!
    
    var notificationObject: NotificationObject?
    var pushTitle: String?
    var pushMessage: String?
    var authAlert: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
    
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
        
        setupNotificationView()
        startTimeoutCount()
        authenticateStart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.timer.invalidate()
        self.context.invalidate()
    }
    
    func setupNotificationView(){
        approveBtn.setTitle("approve_button".localized, for: .normal)
        denyBtn.setTitle("deny_button".localized, for: .normal)
        notificationTitle.text = pushTitle ?? ""
        notificationBody.text = pushMessage ?? ""
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
        if !timer.isValid {
            self.authTimeout()
            return
        }
        
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

            if (self.authAlert.presentingViewController != nil) {
                self.authAlert.dismiss(animated: true, completion: nil)
            }
            
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
        notificationView.isHidden = true
        
        if biometricType == BiometricType.faceID {
            showAlert(title: pushTitle ?? "faceid_consent_title".localized, message: pushMessage ?? "faceid_consent_msg".localized)
        } else {
            self.startBiometricsAuth(policy: .deviceOwnerAuthentication)
        }
    }
        
    func startBiometricsAuth(policy: LAPolicy) {
        
        if !self.timer.isValid {
            self.authTimeout()
        }
        
        var error: NSError?
        
        if context.canEvaluatePolicy(policy, error: &error) {
            let reason = pushMessage ?? "identify_with_biometrics_msg".localized
            
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
                                self?.biometricFallback()
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
            //Biometrics not registered, Approve or Deny with UI on screen
            biometricFallback()
        }
    }
    
    func biometricFallback(){
        notificationView.isHidden = false
        isBiomertics = false
    }
    
    func showAlert(title: String?, message: String?) {
        
        DispatchQueue.main.async {
            self.authAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                       
            let approveAction = UIAlertAction(title: "approve_button".localized, style: UIAlertAction.Style.default) {
               UIAlertAction in
                self.startBiometricsAuth(policy: .deviceOwnerAuthentication)
            }
            let denyAction = UIAlertAction(title: "deny_button".localized, style: UIAlertAction.Style.default) {
               UIAlertAction in
                self.startLoadingAnimation()
                self.denyProcess()
            }
            
            self.authAlert.addAction(denyAction)
            self.authAlert.addAction(approveAction)
            
            self.present(self.authAlert, animated: true, completion: nil)
        }
        
    }
}

