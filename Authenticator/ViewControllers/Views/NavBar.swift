//  
//  NavBar.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit

class NavBar: UIView {

    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scanQRBtn: UIButton!
    @IBOutlet weak var sideMenuBtn: UIButton!
    var navHeight: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView(){
        mainView.backgroundColor = .white
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: navHeight)
    }
    
    func disableNavButtons(){
        sideMenuBtn.isHidden = true
        scanQRBtn.isHidden = true
        sideMenuBtn.isUserInteractionEnabled = false
    }
    
    func enableNavButtons(){
        sideMenuBtn.isHidden = false
        scanQRBtn.isHidden = false
        sideMenuBtn.isUserInteractionEnabled = true
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        if !sideMenuBtn.isHidden {
            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.toggleSideMenuStart), object: nil)
        }
    }
    
    @IBAction func scanQR(_ sender: UIButton) {
        if !scanQRBtn.isHidden {
            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.scanQRMenuTapped), object: nil)
        }
    }
    
}
