//
//  MainTableViewCell.swift
//  Authenticator
//
//  Copyright © 2022 Ping Identity. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    var isFirstCell = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = backgroundView
        
        self.layoutMargins = UIEdgeInsets.zero
        
        setupBorders()
    }

    func setupBorders(){
        if isFirstCell {
            let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width + 20, height: 0.5))
            topBorder.backgroundColor = .customLightGrey
            self.addSubview(topBorder)

            let bottomBorder = UIView(frame: CGRect(x: 0, y: self.frame.size.height - 1.0, width: self.frame.size.width + 20, height: 0.5))
            bottomBorder.backgroundColor = .customLightGrey
            self.addSubview(bottomBorder)
        } else {
            let bottomBorder = UIView(frame: CGRect(x: 0, y: self.frame.size.height - 1.0, width: self.frame.size.width + 20, height: 0.5))
            bottomBorder.backgroundColor = .customLightGrey
            self.addSubview(bottomBorder)
        }
    }

}
