//
//  PairViewController.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit
import AVFoundation
import PingOneSDK

class PairViewController: MainViewController, UITextFieldDelegate, QRCaptureDelegate {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var enableCameraView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var navBar: NavBar!
    
    @IBOutlet weak var enableDescriptionLbl: UILabel!
    @IBOutlet weak var enableCameraBtn: UIButton!
    
    @IBOutlet weak var pairingTitleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    @IBOutlet weak var pairingKeyTextField: UITextField!
    @IBOutlet weak var pairBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var isPairingScreen = true
    private var capture: QRCapture!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        capture = QRCapture()
        capture.delegate = self
    }
    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Handle camera UI
        setupEnableCameraView()
        cameraView.alpha = 0
        cameraView.clipsToBounds = true
        
        // Handle texts
        setupScreenTexts()
        hideNavBarButtons()
  
        // Handle permissions
        DispatchQueue.main.async{
            Defaults.increaseNotificationPermissionCounter()
            if  Defaults.getNotificationPermissionCounter() < DefaultsKeys.maxNotificationPersmissionRequests && Defaults.getNotificationPermissionCounter() != 2 { //Here we prompt user from second time app is opened, since this is already done that on Notifications screen on first time.
                self.checkIfUserRegisteredForNotifications()
            }
            
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .authorized { //Request Access only if needed
                
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted:Bool) -> Void in
                    
                    DispatchQueue.main.async{
                        self.cameraView.alpha = 1
                        self.enableCameraView.isHidden = granted
                        self.enableCameraBtn.isEnabled = !granted
                        self.startCameraPreview()
                    }
                })
            } else {
                self.enableCameraView.alpha = 1
                self.enableCameraView.isHidden = false
                self.enableCameraBtn.isEnabled = true
                self.startCameraPreview()
            }
       }
    }
    
    func startCameraPreview(){
        self.capture.addPreviewLayerTo(self.cameraView, withDelay: false) { (isDone) in
            if isDone {
                UIView.animate(withDuration: 0.25) {
                    self.cameraView.alpha = 1
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.capture.stop()
    }
    
    func setupScreenTexts(){
        // Setup enable button
        if Defaults.isPaired(){
            cancelBtn.isHidden = false
        }
        cancelBtn.isHidden = !Defaults.isPaired()
        
        // Setup texts
        pairingKeyTextField.text = ""
        enableDescriptionLbl.text = "enable_camera_description".localized
        enableCameraBtn.setTitle("enable_button".localized, for: .normal)
        
        pairingTitleLbl.text = isPairingScreen ? "pairing_title".localized : "authentication_title".localized
        descriptionLbl.text = isPairingScreen ? "pairing_description".localized : "authentication_description".localized
    
        if isPairingScreen { // Pairing
            pairingKeyTextField.keyboardType = .numberPad
            pairingTitleLbl.text = "pairing_title".localized
            descriptionLbl.text = "pairing_description".localized
            pairingKeyTextField.attributedPlaceholder = NSAttributedString(string: "pairing_key_placeholder".localized, attributes: [
                .foregroundColor: UIColor.customLightGrey,
                .font: UIFont.italicSystemFont(ofSize: 18)
            ])
            pairBtn.setTitle("pair".localized, for: .normal)
        } else {
            // Authentication with QR
            pairingKeyTextField.keyboardType = .namePhonePad
            pairingTitleLbl.text = "authentication_title".localized
            descriptionLbl.text = "authentication_description".localized
            pairingKeyTextField.attributedPlaceholder = NSAttributedString(string: "authentication_key_placeholder".localized, attributes: [
                .foregroundColor: UIColor.customLightGrey,
                .font: UIFont.italicSystemFont(ofSize: 18)
            ])
            pairBtn.setTitle("authenticate".localized, for: .normal)
        }
        
        pairingKeyTextField.font = UIFont.systemFont(ofSize: 18)
    }
    
    func moveToUsersOnPairingSuccess(){
        self.capture.stop()
        DispatchQueue.main.async {
            if let navigation = self.navigationController as? NavigationController, let story = self.storyboard, let usersVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.UsersVcID) as? UsersViewController {
                navigation.modalTransitionStyle = .crossDissolve
                
                Defaults.addedNewUser()
                
                var wasUsersVCPresented = false
                if let viewControllers = self.navigationController?.viewControllers {
                    for controller in viewControllers {
                        if controller is UsersViewController {
                            wasUsersVCPresented = true
                            break
                        }
                    }
                }

                if wasUsersVCPresented && Defaults.isPaired() {
                    navigation.popViewController(animated: true)
                } else {
                    Defaults.setPaired(isPaired: true)
                    navigation.pushViewController(usersVc, animated: true)
                }
            }
        }
    }
    
    func moveToUsersOnAuthQRSuccess(){
        DispatchQueue.main.async {
            if let navigation = self.navigationController as? NavigationController {
                navigation.modalTransitionStyle = .crossDissolve
                navigation.popViewController(animated: true)
            }
        }
    }
    
    // MARK: Handle permissions
    
    func setupEnableCameraView(){
        enableCameraView.borderColor = UIColor.white
        enableCameraBtn.isEnabled = true
        enableCameraView.isHidden = true
    }
    
    @IBAction func reqeustCameraPermisssionsTapped(_ sender: UIButton){
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted:Bool) -> Void in
            DispatchQueue.main.async{
                if granted {
                    DispatchQueue.main.async{
                        self.enableCameraView.isHidden = granted
                        self.enableCameraBtn.isEnabled = !granted
                        self.startCameraPreview()
                    }
                } else {
                    self.enableCameraView.isHidden = false
                    self.cameraView.isHidden = false
                    
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }

                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)")
                        })
                    }
                }
            }
        })
    }
    
    func checkIfUserRegisteredForNotifications(){
        let center  = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { settings in
            if settings.authorizationStatus != .authorized {
                DispatchQueue.main.async{
                    self.showAlertEnableNotifications()
                }
            }
        })
    }
    
    func showAlertEnableNotifications(){
        let alert = UIAlertController(title: "allow_notifications_title".localized, message: "allow_notificaitons_msg".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "settings".localized, style: .default, handler: { (action) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pairBtnAction(_ sender: UIButton) {
        if let code = pairingKeyTextField.text{
            if isPairingScreen {
                startPairing(code)
            } else {
                startAuthentication(code)
            }
        }
    }
    
    // MARK: Pairing
    
    func startPairing(_ pairingKey: String){
        DispatchQueue.main.async{
            self.view.endEditing(true)
            
            guard let story = self.storyboard else { return }
            let statusVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.StatusVcID) as! StatusViewController
            statusVc.isPairing = true
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("Error accessing AppDelegate")
                return
            }
            statusVc.modalPresentationStyle = .overCurrentContext
            statusVc.modalTransitionStyle = .crossDissolve
            appDelegate.containerVc!.present(statusVc, animated: true, completion: {
                self.pairing(pairingKey, statusVc)
            })
        }
    }
    
    func pairing(_ keyPair: String, _ statusVc: StatusViewController) {
        PingOne.pair(keyPair) { (reponse, error) in
            DispatchQueue.main.async{
                if let error = error{
                    print(error.localizedDescription)
                    statusVc.authStatus = .failure
                    statusVc.message = error.localizedDescription
                    statusVc.failure()
                    self.startCameraPreview()
                } else {
                    statusVc.authStatus = .success
                    statusVc.success()
                    self.moveToUsersOnPairingSuccess()
                }
            }
        }
    }
    
    // MARK: Authentication with QR
    
    func startAuthentication(_ authCode: String) {
        DispatchQueue.main.async{
            self.view.endEditing(true)
            
            guard let story = self.storyboard else { return }
            let statusVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.StatusVcID) as! StatusViewController
            statusVc.isAuthQRCode = true
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("Error accessing AppDelegate")
                return
            }
            statusVc.modalPresentationStyle = .overCurrentContext
            statusVc.modalTransitionStyle = .crossDissolve
            appDelegate.containerVc!.present(statusVc, animated: true, completion: {
                self.authenticateCode(authCode, statusVc)
            })
        }
    }
    
    func authenticateCode(_ authCode: String, _ statusVc: StatusViewController){
        PingOne.authenticate(authCode) { authenticationObject, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.startCameraPreview()
                    print(error.localizedDescription)
                    statusVc.authStatus = .failure
                    statusVc.message = error.localizedDescription
                    statusVc.failure()
                }
                if let authObj = authenticationObject, let status = authObj.status {
                    if status == AuthenticateCode.statusCompleted {
                        // Single user with approval not required, no need for user selection
                        if authObj.userApproval == AuthenticateCode.userApprovalNotRequired && authObj.users?.count == 1 {
                            statusVc.authStatus = .success
                            statusVc.success()
                            statusVc.authObject = authenticationObject
                            self.moveToUsersOnAuthQRSuccess()
                        }
                        // For multiple user and if approval required
                        if authObj.userApproval == AuthenticateCode.userApprovalRequired {
                            statusVc.continueToUsersSelection()
                            self.moveToUserApprovalVC(authObj)
                        }

                    } else if status == AuthenticateCode.statusClaimed {
                        // Flow not completed yet, needs user approval
                        statusVc.continueToUsersSelection()
                        self.moveToUserApprovalVC(authObj)
                        
                    } else if status == AuthenticateCode.statusExpired {
                        self.startCameraPreview()
                        statusVc.authStatus = .timeout
                        statusVc.timeout()
                    }
                }
            }
        }
    }
    
    func moveToUserApprovalVC(_ authObj: AuthenticationObject){
        DispatchQueue.main.async {
            if let navigation = self.navigationController as? NavigationController, let story = self.storyboard, let authCodeVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.AuthCodeVcID) as? AuthCodeViewController {
                authCodeVc.authObject = authObj
                authCodeVc.userWasPicked = false
                navigation.modalTransitionStyle = .crossDissolve
                
                var wasAuthCodeVCPresented = false
                if let viewControllers = self.navigationController?.viewControllers {
                    for controller in viewControllers {
                        if controller is AuthCodeViewController {
                            wasAuthCodeVCPresented = true
                            break
                        }
                    }
                }

                if wasAuthCodeVCPresented {
                    navigation.popToViewController(authCodeVc, animated: true)
                } else {
                    navigation.pushViewController(authCodeVc, animated: true)
                }
            }
        }
    }
    
    // MARK: TextField Delegates
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        pairingKeyTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return true
    }
       
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let minCharCount = isPairingScreen ? DefaultsKeys.minCharactersForPairKey : DefaultsKeys.minCharactersForAuthCode
        
        if var updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string){
            
            if updatedString.count > minCharCount {
                return false
            }
            
            DispatchQueue.main.async{
                
                // Set letter uppercased
                updatedString = updatedString.uppercased()
                textField.text = updatedString
                
                if updatedString.count > minCharCount - 1 {
                    self.pairBtn.isEnabled = true
                    self.pairBtn.borderColor = UIColor.customBlue
                    self.pairBtn.setTitleColor(UIColor.customBlue, for: .normal)
                }
                else{
                    self.pairBtn.isEnabled = false
                    self.pairBtn.borderColor = UIColor.customMedGrey
                    self.pairBtn.setTitleColor(UIColor.black, for: .normal)
                }
            }
        }
        return true
    }
    
    //MARK: QRCameraDelegate
    
    func found(code: String) {
        if self.presentedViewController?.isKind(of: StatusViewController.self) ?? false {
            self.startCameraPreview()
            return
        }
        
        print("found code: \(code)")
        if isPairingScreen {
            startPairing(code)
        } else {
            startAuthentication(code)
        }
    }
    
    func failed(error: String) {
        print(error)
    }
    
    @IBAction func closeVc(_ sender: UIButton) {
        CATransaction.begin()

        CATransaction.setCompletionBlock({
            self.moveToUsers()
        })

        self.view.endEditing(true)
        CATransaction.commit()
    }
    
    func moveToUsers(){
        if let navigation = self.navigationController as? NavigationController, let story = self.storyboard, let usersVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.UsersVcID) as? UsersViewController {
            navigation.modalTransitionStyle = .crossDissolve

            if let viewControllers = self.navigationController?.viewControllers {
                for controller in viewControllers {
                    if let usersViewController = controller as? UsersViewController {
                        navigation.popToViewController(usersViewController, animated: true)
                        return
                    }
                }
            }
            
            navigation.pushViewController(usersVc, animated: true)
        }
    }
}
