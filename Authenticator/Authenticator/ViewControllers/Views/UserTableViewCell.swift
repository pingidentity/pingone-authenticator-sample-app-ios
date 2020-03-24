//
//  UserTableViewCell.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate: class {
    func userNameUpdateDone()
}

class UserTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var userFullnameTextEdit: UITextField!
    @IBOutlet weak var saveUserBtn: UIButton!
    
    var delegate: UserTableViewCellDelegate?
    var synchedUser : User?
    var userFromServer : User?
    
    var isFirstCell = false
    var isEditMode: Bool = false
    var isUsersTableInEditMode: Bool = false
    var usersDictStorage = Defaults.getUsersData()
    
    private enum editImage: String{
        case edit = "icon_edit"
        case save = "button_blue_checkmark"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = backgroundView
        
        setupEditText()
        userFullnameTextEdit.delegate = self
    }

    func setupBorders(){
        if isFirstCell {
            let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0.5))
            topBorder.backgroundColor = .customLightGrey
            self.addSubview(topBorder)

            let bottomBorder = UIView(frame: CGRect(x: 0, y: self.frame.size.height - 1.0, width: self.frame.size.width, height: 0.5))
            bottomBorder.backgroundColor = .customLightGrey
            self.addSubview(bottomBorder)
        } else {
            let bottomBorder = UIView(frame: CGRect(x: 0, y: self.frame.size.height - 1.0, width: self.frame.size.width, height: 0.5))
            bottomBorder.backgroundColor = .customLightGrey
            self.addSubview(bottomBorder)
        }
    }
    
    func setupEditText(){
        userFullnameTextEdit.layer.cornerRadius = 3
        userFullnameTextEdit.layer.masksToBounds = true
        
        userFullnameTextEdit.clearButtonMode = .whileEditing
        userFullnameTextEdit.textColor = .customDarkGrey
        
        userFullnameTextEdit.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: userFullnameTextEdit.frame.height))
        userFullnameTextEdit.leftViewMode = .always
        
        userFullnameTextEdit.borderWidth = 0.5
        userFullnameTextEdit.borderColor = UIColor.clear
    }
       
    @IBAction func saveUserTapped(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error accessing AppDelegate")
            return
        }
        
        if appDelegate.isKeyboardVisible && self.isEditMode {
            startNameEdit()
        } else if appDelegate.isKeyboardVisible && !self.isEditMode{
            return
        } else {
            startNameEdit()
        }
    }
    
    func startNameEdit(){
        
        self.isEditMode = !self.isEditMode
        changeCellEditMode(isEditing: isEditMode)
        
        if !self.isEditMode {
            if let userTextEdit = userFullnameTextEdit.text, let user = synchedUser, let userFromServer = self.userFromServer {
                if userTextEdit.count > 0 {
                    usersDictStorage[user.id] = userTextEdit
                    Defaults.setUserData(id: user.id, name: usersDictStorage[user.id] ?? "")
                }
                else { //Return to server value if cleaned
                    userFullnameTextEdit!.text = "\(userFromServer.name.given ?? "") \(userFromServer.name.family ?? "")"
                    Defaults.setUserData(id: userFromServer.id, name: userFullnameTextEdit!.text ?? "")
                }
                
                self.delegate?.userNameUpdateDone()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        startNameEdit()
        return true
    }
    
    func textFieldShouldBeginEditing( _ textField: UITextField) -> Bool {
        return self.isEditMode
    }
    
    func changeCellEditMode(isEditing: Bool){
        if isEditing {
            userFullnameTextEdit.becomeFirstResponder()
            startUserEditing()
        } else {
            userFullnameTextEdit.resignFirstResponder()
            endUserEditing()
        }
    }
    
    func startUserEditing(){
        userFullnameTextEdit.borderColor = UIColor.customLightGrey
        
        let imageName = editImage.save
        let editImageName = UIImage(named: imageName.rawValue)
        saveUserBtn.setImage(editImageName, for: .normal)
    }
    
    func endUserEditing(){
        userFullnameTextEdit.borderColor = UIColor.clear
        
        let imageName = editImage.edit
        let editImageName = UIImage(named: imageName.rawValue)
        saveUserBtn.setImage(editImageName, for: .normal)
    }

}
