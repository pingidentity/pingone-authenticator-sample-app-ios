//
//  ContainerVC.swift
//  Authenticator
//
//  Created by Amit Nadir on 26/01/2020.
//  Copyright © 2020 Ping Identity. All rights reserved.
//

import UIKit

class ContainerVC: UIViewController {

    @IBOutlet weak var sideMenuWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewContainer: UIView!
    
    let overlayView = UIView()
    let shadeView = UIView()
    var sideMenuOpen = false
    private let sideGap : CGFloat = UIScreen.main.bounds.size.width * 0.45
    private let darkMode : CGFloat = 0.3
    private let clearMode : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Start listening to side menu open post notificaitons
        NotificationCenter.default.addObserver(self,selector: #selector(toggleSideMenu), name: NSNotification.Name("ToggleSideMenu"), object: nil)
        
        //Set up gesture to close side menu
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOverlayViewTap))
        self.overlayView.addGestureRecognizer(tap)
        
        //Setup container views initial width
        sideMenuWidthConstraint.constant = 0
        
    }
    
    func initOverlayView(){      
        overlayView.backgroundColor = .black
        overlayView.alpha = darkMode
        overlayView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
               
        if let topController = UIApplication.topViewController() {
            topController.view.addSubview(overlayView)
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
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.overlayView.frame = (self.sideMenuOpen) ? openRect : closedRect
                self.overlayView.alpha = (self.sideMenuOpen) ? self.darkMode : self.clearMode
                self.view.layoutIfNeeded()
            }) { (staus) in
                NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenuEnded"), object: nil)
            }
        }
    }
    
    @objc func handleOverlayViewTap(){
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
}
