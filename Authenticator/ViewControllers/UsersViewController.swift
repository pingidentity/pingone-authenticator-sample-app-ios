//
//  UsersViewController.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit
import PingOneSDK

class UsersViewController: MainViewController, UITableViewDelegate, UITableViewDataSource, UserTableViewCellDelegate {

    @IBOutlet weak var PasscodeView: PasscodeView!
    @IBOutlet weak var usersTableView: DynamicTableView!
    @IBOutlet weak var usersTableTitleLbl: UILabel!
    @IBOutlet weak var addNewUserBtn: UIButton!
    @IBOutlet weak var passcodeViewTopConstraint: NSLayoutConstraint!
    
    private var activeUser: ActiveUser = ActiveUser()
    private let usersHandler: UsersHandler = UsersHandler()
    private var activeUsersArray: [User]?
    private var usersFromServer: [User]?
    
    private var usersDictStorage = Defaults.getUsersData()
    private var isNewUserAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(scanQRMenuTapped), name: NSNotification.Name(NotificationKeys.scanQRMenuTapped), object: nil)
        setupScreen()
        setupPasscode()
    }
    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUsers()
    }

    func setupScreen() {
        usersTableView.separatorColor = UIColor.clear
        
        usersTableTitleLbl.text = "users_table_title".localized
        addNewUserBtn.setTitle("add_new_user_button".localized, for: .normal)
    }
    
    private func setupPasscode() {
        PingOne.getOneTimePasscode { [weak self] (passcodeData, error) in
            guard let self = self else {
                return
            }
            self.handlePasscode(passcodeData, error)
        }
    }
    
    private func handlePasscode(_ oneTimePasscodeInfo: OneTimePasscodeInfo?, _ error: Error?) {
        DispatchQueue.main.async {
            if let _ = error {
                self.PasscodeView.isHidden = true
                return
            }
            
            guard let passcodeData = oneTimePasscodeInfo else {
                return
            }
            
            self.PasscodeView.update(passcode: passcodeData)
            self.PasscodeView.isHidden = false
            self.PasscodeView.delegate = self
        }
    }
    
    @objc private func scanQRMenuTapped() {
        if let navigation = self.navigationController as? NavigationController, let story = self.storyboard, let authCodeVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.AuthScanVcID) as? AuthCodeScanViewController {
            navigation.modalTransitionStyle = .crossDissolve
            
            if let viewControllers = self.navigationController?.viewControllers {
                for controller in viewControllers {
                    if controller is AuthCodeScanViewController {
                        if let pairingViewController = controller as? AuthCodeScanViewController {
                            navigation.popToViewController(pairingViewController, animated: true)
                            return
                        }
                    }
                }
            }

            navigation.pushViewController(authCodeVc, animated: true)
        }
    }
    
    // MARK: Load Users
    
    func getUsers() {
        startLoadingAnimation()
        PingOne.getInfo { (activeUsers, error) in
                if let error = error {
                    self.stopLoadingAnimation()
                    if error.code == ErrorCode.deviceIsNotPaired.rawValue {
                        Defaults.setPaired(isPaired: false)
                    }
                }
                
                if let activeUsers = activeUsers {
                    
                    // Handle users synch and table reload
                    guard let usersFromServer = self.activeUser.setUserData(data: activeUsers) else { return }
                    self.usersFromServer = usersFromServer
                    self.activeUsersArray = self.usersHandler.getSynchedUsers(usersFromServer)
                    let isActiveUsersArrayEmpty = self.activeUsersArray?.isEmpty ?? true
                    
                    if self.usersHandler.isNewUserAdded() && !isActiveUsersArrayEmpty {
                        self.startEditNewUserIfNeeded()
                        self.usersHandler.addedUserReset()
                        return
                    }
                    
                    self.stopLoadingAnimation()
                    
                    // In case there are no users
                    if isActiveUsersArrayEmpty {
                        Defaults.setPaired(isPaired: false)
                        self.moveToPairing()
                    }
                
                    DispatchQueue.main.async {
                        self.usersTableView.reloadData()
                        self.setupPasscode()
                    }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeUsersArray?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UserTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: DefaultsKeys.userTableViewCellKey) as! UserTableViewCell)
        cell?.delegate = self
        
        let userFromServer = self.usersFromServer?[indexPath.row]
        cell?.userFromServer = userFromServer
        
        let user = activeUsersArray?[indexPath.row]
        cell?.synchedUser = user
        
        let userName = "\(user?.name.given ?? "") \(user?.name.family ?? "")"
        cell?.userFullnameTextEdit!.text = userName
        
        // Default user name
        if userName.trimmingCharacters(in: .whitespaces).isEmpty {
            cell?.userFullnameTextEdit!.text = "User 0\(indexPath.row + 1)"
        }
        
        // Get user name from local storage if exists
        if let userID = user?.id, let userNameFromStorage = usersDictStorage[userID], !userNameFromStorage.trimmingCharacters(in: .whitespaces).isEmpty {
            cell?.userFullnameTextEdit!.text = userNameFromStorage
        }
       
        // Layout cell
        if indexPath.row == 0 && cell?.isFirstCell == false {
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
    
    func startEditNewUserIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.view.isUserInteractionEnabled = false
            self.view.layoutIfNeeded()
            self.usersTableView.reloadData()
            
            guard let lastObject = self.activeUsersArray?.count else { return }
            let indexPath = IndexPath(item: lastObject - 1, section: 0)
            self.usersTableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            
            let cell: UserTableViewCell? = self.usersTableView.cellForRow(at: indexPath) as? UserTableViewCell
            self.view.layoutIfNeeded()
            
            cell?.isEditMode = true
            cell?.userFullnameTextEdit.becomeFirstResponder()
            cell?.startUserEditing()
            self.view.isUserInteractionEnabled = true
            self.stopLoadingAnimation()
        }
    }
    
    func moveToPairing() {
        DispatchQueue.main.async {
            if let navigation = self.navigationController as? NavigationController, let story = self.storyboard, let pairVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.PairVcID) as? PairViewController {
                self.usersTableView.reloadData()
                navigation.modalTransitionStyle = .crossDissolve
                
                var wasPairingVCPresented = false
                if let viewControllers = self.navigationController?.viewControllers {
                    for controller in viewControllers {
                        if controller is PairViewController {
                            navigation.popToViewController(controller, animated: true)
                            wasPairingVCPresented = true
                            break
                        }
                    }
                }

                if !wasPairingVCPresented {
                    navigation.pushViewController(pairVc, animated: true)
                }
            }
        }
    }
    
    // MARK: handle UserTableViewCellDelegate
    
    func userNameUpdateDone() {
        if let users = self.usersFromServer {
            self.activeUsersArray = self.usersHandler.getSynchedUsers(users)
            self.usersDictStorage = Defaults.getUsersData()
            self.usersTableView.reloadData()
        }
    }
}

extension UsersViewController: PasscodeViewDelegateProtocol {
    func didTappedView() {
        if let navigation = self.navigationController as? NavigationController {
            AlertBanner.temporary(navBar: navigation.navBar, title: Alert.copied, animate: true, tag: .passCodeCopied)
        }
    }
    
    func didAskForPasscode() {
        PingOne.getOneTimePasscode { [weak self] (passcodeData, error) in
            guard let self = self else {
                return
            }
            self.handlePasscode(passcodeData, error)
        }
    }
}
