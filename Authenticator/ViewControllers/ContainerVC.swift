//
//  ContainerVC.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit

class ContainerVC: MainViewController {

    @IBOutlet weak var sideMenuWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewContainer: UIView!
    
    private let overlayView = UIView()
    private let shadeView = UIView()
    private var sideMenuOpen = false
    private let sideGap : CGFloat = UIScreen.main.bounds.size.width * 0.45
    private let darkMode : CGFloat = 0.3
    private let clearMode : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,selector: #selector(toggleSideMenu), name: NSNotification.Name(NotificationKeys.toggleSideMenuStart), object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOverlayViewTap))
        self.overlayView.addGestureRecognizer(tap)
        
        //Setup container views initial width
        sideMenuWidthConstraint.constant = 0
    }
    
    func deint(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationKeys.toggleSideMenuStart), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationKeys.toggleSideMenuEnd), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationKeys.sendLogs), object: nil)
    }
    
    func initOverlayView(){      
        overlayView.backgroundColor = .black
        overlayView.alpha = self.clearMode
        overlayView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        if let topController = UIApplication.topViewController() {
            topController.view.addSubview(overlayView)
        }
        
        UIView.animate(withDuration: 0.35) {
            self.overlayView.alpha = self.darkMode
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func toggleSideMenu() {
        if !sideMenuOpen {
            initOverlayView()
        }
        
        if sideMenuOpen {
            sideMenuOpen = false
            sideMenuWidthConstraint.constant = 0
            
        } else {
            sideMenuOpen = true
            sideMenuWidthConstraint.constant = sideGap
        }
        
        let openRect = CGRect(x: 0, y: 0, width: self.view.frame.width - self.sideGap, height: self.view.frame.height)
        let closedRect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        //Open side menu
        if sideMenuOpen {UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 12, options: .curveEaseInOut, animations: {
                self.overlayView.frame = (self.sideMenuOpen) ? openRect : closedRect
                self.overlayView.alpha = (self.sideMenuOpen) ? self.darkMode : self.clearMode
                self.view.layoutIfNeeded()
            }) { _ in
            }
        } else { //Close side menu
            UIView.animate(withDuration: 0.5, delay: 0, animations: {
                self.overlayView.frame = (self.sideMenuOpen) ? openRect : closedRect
                self.overlayView.alpha = (self.sideMenuOpen) ? self.darkMode : self.clearMode
                self.view.layoutIfNeeded()
            }) { (staus) in
                NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.toggleSideMenuEnd), object: nil)
            }
        }
    }
    
    @objc func handleOverlayViewTap(){
        NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.toggleSideMenuStart), object: nil)
    }
}
