//
//  HomeViewController.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit
import PingOne

class UsersViewController: MainViewController, UITableViewDelegate, UITableViewDataSource, UserTableViewCellDelegate {

    @IBOutlet weak var usersTableView: DynamicTableView!
    @IBOutlet weak var usersTableTitleLbl: UILabel!
    @IBOutlet weak var addNewUserBtn: UIButton!
    
    private var activeUser : ActiveUser = ActiveUser()
    private let usersHandler : UsersHandler = UsersHandler()
    private var activeUsersArray: [User]?
    private var usersFromServer: [User]?
    
    private var usersDictStorage = Defaults.getUsersData()
    private var isGetUsersFired = false
    private var isNewUserAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardNotifications()
        setupScreen()
        getUsers()
        isGetUsersFired = true
    }
    
    //MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigation = self.navigationController as? NavigationController {
            navigation.navBar.sideMenuBtn.isHidden = false
            navigation.navBar.sideMenuBtn.isUserInteractionEnabled = true
            navigation.navigationBar.isHidden = false
            navigation.navBar.isHidden = false
            navigation.navBar.layer.applySketchShadow(color: .lightGray)
        }

        self.keyboardHeightFactor = 0.8
        if !isGetUsersFired {
            self.isGetUsersFired = true
            getUsers()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.isGetUsersFired = false
    }
    
    deinit {
        removeKeyboardNotifications()
    }

    func setupScreen(){
        usersTableView.separatorColor = UIColor.clear
        
        usersTableTitleLbl.text = "users_table_title".localized
        addNewUserBtn.setTitle("add_new_user_button".localized, for: .normal)
    }
    
    //MARK: Load Users
    
    func getUsers(){
        startLoadingAnimation()
            
        PingOne.getInfo { (activeUsers, error) in
        
            DispatchQueue.main.async {
                if let activeUsers = activeUsers{
                
                    if !self.isGetUsersFired { return }
                    
                    //Handle users synch and table reload
                    if let usersFromServer = self.activeUser.setUserData(data: activeUsers) {
                        self.usersFromServer = usersFromServer
                        self.activeUsersArray = self.usersHandler.getSynchedUsers(usersFromServer)
                        let isActiveUsersArrayEmpty = self.activeUsersArray?.isEmpty ?? true
                        
                        if self.usersHandler.isNewUserAdded() && !isActiveUsersArrayEmpty {
                            self.startEditNewUserIfNeeded()
                            self.stopLoadingAnimation()
                            self.usersHandler.addedUserReset()
                            return
                        }
                        
                        if isActiveUsersArrayEmpty && self.isGetUsersFired { //No users
                            Defaults.setPaired(isPaired: false)
                            self.moveToPairing()
                        } else {
                            self.usersTableView.reloadData()
                        }
                        self.stopLoadingAnimation()
                    }

                } else
                    if let error = error{
                        if error.code == ErrorCode.deviceIsNotPaired.rawValue{
                            Defaults.setPaired(isPaired: false)
                        }
                    }
                
                self.usersHandler.addedUserReset()
                self.stopLoadingAnimation()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return activeUsersArray?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell : UserTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: DefaultsKeys.userTableViewCellKey) as! UserTableViewCell)
        cell?.delegate = self
        
        let userFromServer = self.usersFromServer?[indexPath.row]
        cell?.userFromServer = userFromServer
        
        let user = activeUsersArray?[indexPath.row]
        cell?.synchedUser = user
        
        let userName = "\(user?.name.given ?? "") \(user?.name.family ?? "")"
        cell?.userFullnameTextEdit!.text = userName
        
        //Default user name
        if userName.trimmingCharacters(in: .whitespaces).isEmpty {
            cell?.userFullnameTextEdit!.text = "User 0\(indexPath.row + 1)"
        }
        
        //Get user name from local storage if exists
        if let userID = user?.id, let userNameFromStorage = usersDictStorage[userID], !userNameFromStorage.trimmingCharacters(in: .whitespaces).isEmpty {
            cell?.userFullnameTextEdit!.text = userNameFromStorage
        }
       
        //Layout cell
        if indexPath.row == 0 && cell?.isFirstCell == false{
            cell?.isFirstCell = true
        }
        cell?.setupBorders()
        cell?.endUserEditing()
        
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return usersTableView.cellHeight
    }

    @IBAction func addUser(_ sender: UIButton) {
        self.view.endEditing(true)
        moveToPairing()
    }
    
    func startEditNewUserIfNeeded(){
        self.view.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            self.view.layoutIfNeeded()
            self.usersTableView.reloadData()
            
            guard let lastObject = self.activeUsersArray?.count else { return }
            let indexPath = IndexPath(item: lastObject - 1, section: 0)
            self.usersTableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            
            let cell : UserTableViewCell? = self.usersTableView.cellForRow(at: indexPath) as? UserTableViewCell
            self.view.layoutIfNeeded()
            
            cell?.isEditMode = true
            cell?.userFullnameTextEdit.becomeFirstResponder()
            cell?.startUserEditing()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func moveToPairing(){
        if let navigation = self.navigationController as? NavigationController, let story = self.storyboard{
            let pairVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.PairVcID) as! PairViewController
            self.usersTableView.reloadData()
            
            navigation.modalTransitionStyle = .crossDissolve
            navigation.pushViewController(pairVc, animated: true)
        }
    }
    
    //MARK: handle UserTableViewCellDelegate
    
    func userNameUpdateDone(){
        if let users = self.usersFromServer {
            self.activeUsersArray = self.usersHandler.getSynchedUsers(users)
            self.usersDictStorage = Defaults.getUsersData()
            self.usersTableView.reloadData()
        }
    }
}
