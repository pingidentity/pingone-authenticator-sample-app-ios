//
//  MainViewController.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    private var spinner = UIActivityIndicatorView(style: .gray)
    private var reachability: Reachability?
    
    var viewOriginY : CGFloat = 0
    var keyboardHeightFactor : CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupReachability()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewOriginY = self.view.frame.origin.y //Anchor for keyboard location calculation
    }
    
    func setupReachability(){
        if let navController = self.navigationController as? NavigationController{
            let navBar = navController.navBar
            let reachability: Reachability?
            reachability = try? Reachability()
            self.reachability = reachability
            
            do {
                try reachability?.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
            
            reachability?.whenReachable = { reachability in
                print("Reachable")
                AlertBanner.hidePersistent(.noConnectivity, navBar: navBar)
            }
            reachability?.whenUnreachable = { reachability in
                print("Not reachable")
                AlertBanner.persistent(navBar: navBar, title: "network_error".localized, animate: true, tag: .noConnectivity)
            }
        }
    }
    
    //MARK: Loading Spinner methods
    
    func startLoadingAnimation(){
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        spinner.isHidden = false
        self.view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func stopLoadingAnimation(){
        spinner.stopAnimating()
        spinner.isHidden = true
    }
    
    // MARK: Handle Keyboard Raise
    
    func addKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let factor = keyboardHeightFactor
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height * factor
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error accessing AppDelegate")
            return
        }
        appDelegate.isKeyboardVisible = true
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        var navBarHeight : CGFloat = 0
        
        if let navController = self.navigationController as? NavigationController{
            let navBar = navController.navBar
            navBarHeight = navBar.frame.height
        }
            
        if view.frame.origin.y != navBarHeight {
            self.view.frame.origin.y = navBarHeight
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error accessing AppDelegate")
            return
        }
        appDelegate.isKeyboardVisible = false
    }

}
