//
//  UserQRAuthTableViewCell.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit

class UserQRAuthTableViewCell: MainTableViewCell {

    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var userTitleLbl: UILabel!
    @IBOutlet weak var userSubTitleLbl: UILabel!
    
    var isCheckmarkOn = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCheckmarkOn() {
        selectedImageView.image = UIImage.init(named: AssetsName.checkmarkOn)
    }
    
    func setCheckmarkOff() {
        selectedImageView.image = UIImage.init(named: AssetsName.checkmarkOff)
    }
    
    func setCheckmarkHidden() {
        selectedImageView.isHidden = true
    }

}
