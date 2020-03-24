//
//  MenuTableViewCell.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle =  UITableViewCell.SelectionStyle.none
        self.menuNameLbl.textColor = UIColor.customBlue
        
        setupBorder()
    }
    
    func setupBorder(){
        let topBorder = CALayer()
        topBorder.borderColor = UIColor.customUltraLight.cgColor
        topBorder.borderWidth = 2
        topBorder.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 1)
        self.layer.addSublayer(topBorder)

        let bottomBorder = CALayer()
        bottomBorder.borderColor = UIColor.customUltraLight.cgColor
        bottomBorder.borderWidth = 2
        bottomBorder.frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 1)
        self.layer.addSublayer(bottomBorder)
    }
    
}
