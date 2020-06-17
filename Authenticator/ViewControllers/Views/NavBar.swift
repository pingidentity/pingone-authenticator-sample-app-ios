//  
//  NavBar.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit

class NavBar: UIView {

    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sideMenuBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView(){
        mainView.backgroundColor = .white
        let navHeight = UIScreen.main.bounds.size.height * 0.12
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: navHeight)
        
        self.layer.applySketchShadow()
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        if !sideMenuBtn.isHidden {
            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.toggleSideMenuStart), object: nil)
        }
    }
}
