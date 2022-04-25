//
//  AuthCodeViewController.swift
//  Authenticator
//
//  Copyright © 2022 Ping Identity. All rights reserved.
//

import UIKit
import PingOneSDK

class AuthCodeViewController: MainViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var usersTableView: DynamicTableView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    
    @IBOutlet weak var subtitleBottomToTableConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var denyBtn: UIButton!
    
    var authObject: AuthenticationObject? {
        didSet {
            usersArray = AuthUserHandler().createUsersArray(authObject?.users ?? [[:]])
            selectedUser = usersArray?.first // Defualt user to authenticate
        }
    }
    
    var usersArray: [User]?
    var selectedUser: User?
    var userWasPicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usersTableView.reloadData()
        setApproveDisabled()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBarButtons()
        setupScreenTexts()
    }
    
    func setupScreenTexts(){
        // Single user setup
        if usersArray?.count == 1 {
            titleLbl.text = "approve_account_title".localized
            subTitleLbl.text = ""
            subtitleBottomToTableConstraint.constant = 10
        } else {
            // Multiple users
            titleLbl.text = "select_account_title".localized
            subTitleLbl.text = "select_account_subtitle".localized
            subtitleBottomToTableConstraint.constant = 16
        }
    }
    
    func setApproveDisabled(){
        if usersArray?.count == 1 {
            return
        }
        
        approveBtn.setTitleColor(.customLightGreen, for: .normal)
        approveBtn.borderColor = .customLightGreen
        approveBtn.isUserInteractionEnabled = false
    }
    
    func setApproveEnabled(){
        approveBtn.setTitleColor(.customGreen, for: .normal)
        approveBtn.borderColor = .customGreen
        approveBtn.isUserInteractionEnabled = true
    }
    
    // MARK: Users tableview methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = (tableView.dequeueReusableCell(withIdentifier: DefaultsKeys.userQRAuthTableViewCell) as? UserQRAuthTableViewCell) {
            
            let user = usersArray?[indexPath.row]
            cell.userTitleLbl.text = "\(user?.name.given ?? "") \(user?.name.family ?? "")"
            cell.userSubTitleLbl.text = "\(user?.username ?? "")"
            
            // Layout cell
            if indexPath.row == 0 && cell.isFirstCell == false{
                cell.isFirstCell = true
            }
            
            // FOr single user, no need for checkmark icon
            if usersArray?.count == 1 {
                cell.setCheckmarkHidden()
            }
            cell.setupBorders()
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return usersTableView.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = (tableView.dequeueReusableCell(withIdentifier: DefaultsKeys.userQRAuthTableViewCell) as? UserQRAuthTableViewCell) {
            
            // Handle UI
            setApproveEnabled()
            cell.setCheckmarkOn()
            
            // Update user picked
            userWasPicked = true
            selectedUser = usersArray?[indexPath.row]
        }
    }
    
    // MARK: Handle Authentication Claim
    
    @IBAction func approveBtnTapped(_ sender: Any) {
        guard let user = selectedUser else { return }
        guard let authObject = authObject else { return }
    
        DispatchQueue.main.async {
            self.approveAuthentication(user, authObject)
        }
    }
    
    @IBAction func denyBtnTapped(_ sender: Any) {
        // Set default user
        var user: User?
        
        // If only one user exists and not picked
        if let usersArray = usersArray, usersArray.count == 1, let firstUser = self.usersArray?.first {
            user = firstUser
        }
        
        // If user was picked
        if userWasPicked, let seletedUser = self.selectedUser {
            user = seletedUser
        }
        
        // Make sure AuthenticationObject exists
        guard let authObject = self.authObject else { return }
        
        DispatchQueue.main.async {
            self.denyAuthentication(user, authObject)
        }
    }
    
    func approveAuthentication(_ userSelected: User, _ authObject: AuthenticationObject){
        
        // Prepare status viewcontroller
        guard let story = self.storyboard else { return }
        let statusVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.StatusVcID) as! StatusViewController
        statusVc.isAuthQRCode = true
        statusVc.modalPresentationStyle = .overCurrentContext
        statusVc.modalTransitionStyle = .crossDissolve
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error accessing AppDelegate")
            return
        }
        
        // Move to status viewcontroller and present results
        appDelegate.containerVc!.present(statusVc, animated: true, completion: {
            authObject.approve(userId: userSelected.id, completionHandler: { status, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                        statusVc.authStatus = .failure
                        statusVc.message = error.localizedDescription
                        statusVc.failure()
                    }
                    
                    if let serverStatus = status, serverStatus == AuthenticateCode.statusCompleted {
                        statusVc.authStatus = .success
                        statusVc.success()
                    } else if status == AuthenticateCode.statusExpired {
                        statusVc.authStatus = .timeout
                        statusVc.timeout()
                    }
                    
                    // Go back to user screen when flow is done
                    self.moveToUsersVC()
                }
            })
        })
    }
    
    func denyAuthentication(_ userSelected: User?, _ authObject: AuthenticationObject){
        
        // Prepare status viewcontroller
        guard let story = self.storyboard else { return }
        let statusVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.StatusVcID) as! StatusViewController
        statusVc.isAuthQRCode = true
        statusVc.modalPresentationStyle = .overCurrentContext
        statusVc.modalTransitionStyle = .crossDissolve
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error accessing AppDelegate")
            return
        }
        
        // Move to status viewcontroller and present results
        appDelegate.containerVc!.present(statusVc, animated: true, completion: {
            authObject.deny(userSelected?.id, completionHandler: { status, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                        statusVc.authStatus = .failure
                        statusVc.message = error.localizedDescription
                        statusVc.failure()
                    }
                    
                    if let serverStatus = status {
                        if serverStatus == AuthenticateCode.statusDenied {
                            statusVc.authStatus = .deny
                            statusVc.denied()
                        } else if serverStatus == AuthenticateCode.statusExpired {
                            statusVc.authStatus = .timeout
                            statusVc.timeout()
                        }
                    }
                    
                    // Go back to user screen when flow is done
                    self.moveToUsersVC()
                }
            })
        })
    }
    
    func moveToUsersVC(){
        DispatchQueue.main.async {
            if let navigation = self.navigationController as? NavigationController, let story = self.storyboard, let usersVc = story.instantiateViewController(withIdentifier: ViewControllerKeys.UsersVcID) as? UsersViewController  {
                navigation.modalTransitionStyle = .crossDissolve
                
                var wasUsersVCPresented = false
                for controller in navigation.viewControllers {
                    if controller is UsersViewController {
                        navigation.popToViewController(controller, animated: true)
                        wasUsersVCPresented = true
                        break
                    }
                }
                
                if !wasUsersVCPresented {
                    navigation.pushViewController(usersVc, animated: true)
                }
            }
        }
    }
}
