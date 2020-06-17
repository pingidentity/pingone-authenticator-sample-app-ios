//
//  ViewController.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit
import AVFoundation
import PingOne

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
    
    private var capture: QRCapture!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScreenTexts()
        
        capture = QRCapture()
        capture.delegate = self
        self.cameraView.clipsToBounds = true
    
        setupEnableCameraView()
        
        addKeyboardNotifications()
        
        self.navBar.layer.applySketchShadow(color: .darkGray)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLayoutSubviews(){
        if Defaults.isPaired(){
            cancelBtn.isHidden = false
        }
        if  self.presentedViewController?.isKind(of: StatusViewController.self) ?? false{
            return
        }
        self.capture.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cameraView.alpha = 0
        self.keyboardHeightFactor = 1.2
        
        //Reset Views
        if Defaults.isPaired(){
            self.cancelBtn.isHidden = false
        }
        
        //Reset navigationBar
        if let navigation = self.navigationController as? NavigationController {
            navigation.navBar.sideMenuBtn.isHidden = true
            navigation.navBar.sideMenuBtn.isUserInteractionEnabled = false
            navigation.navigationBar.isHidden = false
            navigation.navBar.isHidden = false
            navigation.navBar.layer.applySketchShadow(color: .darkGray)
        }

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
                self.enableCameraView.isHidden = true
                self.enableCameraBtn.isEnabled = false
                self.startCameraPreview()
            }
       }
    }
    
    func startCameraPreview(){
        self.capture.addPreviewLayerTo(self.cameraView, withDelay: false) { (isDone) in
            if isDone {
                self.capture.start()
                UIView.animate(withDuration: 0.25) {
                    self.cameraView.alpha = 1
                }
            }
        }
    }
    
    func didFinishCapture(){
        self.capture.addPreviewLayerTo(self.cameraView, withDelay: true) { (isDone) in
            if isDone {
                self.capture.start()
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
    
    deinit {
        removeKeyboardNotifications()
    }
    
    func setupScreenTexts(){
        enableDescriptionLbl.text = "enable_camera_description".localized
        enableCameraBtn.setTitle("enable_button".localized, for: .normal)
        pairingTitleLbl.text = "pairing_title".localized
        descriptionLbl.text = "pairing_description".localized
        
        pairingKeyTextField.attributedPlaceholder = NSAttributedString(string: "pairing_key_placeholder".localized, attributes: [
            .foregroundColor: UIColor.customLightGrey,
            .font: UIFont.italicSystemFont(ofSize: 18)
        ])
        
        pairingKeyTextField.font = UIFont.systemFont(ofSize: 18)
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
        if let pairingKey = pairingKeyTextField.text{
          startPairing(pairingKey)
        }
    }
    
    // MARK: Pairing
    
    func startPairing(_ withPairingKey: String){
        DispatchQueue.main.async{
            self.view.endEditing(true)
            
            if let story = self.storyboard{
                let statusVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.StatusVcID) as! StatusViewController
                statusVc.isAuth = false
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    print("Error accessing AppDelegate")
                    return
                }
                statusVc.modalPresentationStyle = .overCurrentContext
                statusVc.modalTransitionStyle = .crossDissolve
                appDelegate.containerVc!.present(statusVc, animated: true, completion: {
                 
                //Start pairing
                PingOne.pair(withPairingKey) { (error) in
                    if let error = error{
                        print(error.localizedDescription)
                        
                        DispatchQueue.main.async{
                            statusVc.authStatus = .failure
                            statusVc.message = error.localizedDescription
                            statusVc.failure()
                            self.didFinishCapture()
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            statusVc.authStatus = .success
                            statusVc.success()
                            self.moveToUsersOnSuccess()
                        }
                    }
                }
                
                })
            }
        }
    }
    
    func moveToUsersOnSuccess(){
        DispatchQueue.main.async {
            if let navigation = self.navigationController as? NavigationController, let story = self.storyboard{
                let usersVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.UsersVcID) as! UsersViewController
                navigation.modalTransitionStyle = .crossDissolve
                
                Defaults.addedNewUser()
                
                if Defaults.isPaired() {
                    navigation.popViewController(animated: true)
                } else {
                    Defaults.setPaired(isPaired: true)
                    navigation.pushViewController(usersVc, animated: true)
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
        if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string){
            
            if updatedString.count > DefaultsKeys.minCharactersForPairKey {
                return false
            }
            
            DispatchQueue.main.async{
                if updatedString.count > DefaultsKeys.minCharactersForPairKey - 1 {
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
        startPairing(code)
    }
    
    func failed(error: String) {
        print(error)
    }
    
    @IBAction func closeVc(_ sender: UIButton) {
       if let navigation = self.navigationController as? NavigationController {
            navigation.modalTransitionStyle = .crossDissolve
            navigation.popViewController(animated: true)
        }
    }
}
