//  
//  NavBar.swift
//  Authenticator
//
//  Created by Segev Sherry on 12/10/19.
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
        sideMenuBtn.isHidden = true
        mainView.backgroundColor = .white
        let navHeight = UIDevice.isIphoneX ? UIScreen.main.bounds.size.height * 0.12 : UIScreen.main.bounds.size.height * 0.09
        let navYposition = CGFloat(UIDevice.isIphoneX ? 0 : 16)
        self.frame = CGRect(x: 0, y: navYposition, width: UIScreen.main.bounds.size.width, height: navHeight)
        
        self.layer.applySketchShadow()
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
}
