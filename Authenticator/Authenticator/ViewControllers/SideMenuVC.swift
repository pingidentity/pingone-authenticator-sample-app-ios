//
//  SideMenuVC.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit
import PingOne

class SideMenuVC: MainViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var menuTableView: UITableView!
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var upperViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ticketIdLbl: UILabel!
    @IBOutlet weak var versionLbl: UILabel!
    
    private var menuItems : NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupListeners()
        setupHeader()
        setupActionsTable()
        setupLowerDetailsLables()
        loadActions()
    }
    
    func setupListeners(){
        NotificationCenter.default.addObserver(self,selector: #selector(sideMenuWasToggled), name: NSNotification.Name(NotificationKeys.toggleSideMenuStart), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(sideMenuWasToggleEnded), name: NSNotification.Name(NotificationKeys.toggleSideMenuEnd), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(sendLogs), name: NSNotification.Name(NotificationKeys.sendLogs), object: nil)
    }
    
    func setupActionsTable(){
        if Defaults.getSupportID().count > 0 {
           self.ticketIdLbl.text = "Support ID: \(Defaults.getSupportID())"
        } else {
           self.ticketIdLbl.text = ""
        }
        
        let cell = UINib(nibName: DefaultsKeys.menuTableViewCellKey, bundle: nil)
        menuTableView.register(cell, forCellReuseIdentifier: DefaultsKeys.menuTableViewCellKey)
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        menuTableView.isScrollEnabled = false
        menuTableView.reloadData()
    }
    
    func loadActions(){
        if Defaults.isPaired() {
            menuItems[0] = DefaultsKeys.sendLogsKey
        }
        menuTableView.reloadData()
    }
    
    func setupHeader(){
        let navBar: NavBar = UIView.fromNib()
        upperView.frame = navBar.frame
        upperView.backgroundColor = .white
        upperViewHeightConstraint.constant = navBar.frame.height
        self.view.setNeedsLayout()
    }
    
    func setupLowerDetailsLables(){
        ticketIdLbl.textColor = UIColor.lightGray
        ticketIdLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        versionLbl.textColor = UIColor.lightGray
        versionLbl.font = UIFont.systemFont(ofSize: 10)
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "0"
        
        versionLbl.text = "v\(version) (\(build))"
    }
    
    //MARK: Tableview delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DefaultsKeys.menuTableViewCellKey, for: indexPath) as! MenuTableViewCell
        switch indexPath.row {
            case 0:
                cell.menuNameLbl.text = "send_logs".localized
            default:
                cell.menuNameLbl.text = "send_logs".localized
        }
        return cell
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.toggleSideMenuStart), object: nil)
        
        switch indexPath.row {
            case 0: NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.sendLogs), object: nil)
        default:
            break
        }
    }
    
    //MARK: Handle Notifications
    
    @objc func sideMenuWasToggled(){
        loadActions()
        dropShadowForSideMenu()
    }

    func dropShadowForSideMenu() {
        let offSet: CGFloat = 7.0
        self.view.layer.masksToBounds = false
        self.view.layer.shadowColor = UIColor.gray.cgColor
        self.view.layer.shadowOpacity = 0.35
        self.view.layer.shadowOffset = CGSize(width: -offSet, height: 1)
        self.view.layer.shadowPath = UIBezierPath(rect: CGRect(x: 5, y: 0, width: self.view.bounds.size.width + offSet*2, height: self.view.bounds.size.height)).cgPath
        self.view.layer.shouldRasterize = true
        self.view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    @objc func sideMenuWasToggleEnded() {
        self.view.layer.shadowColor = UIColor.clear.cgColor
    }
    
    @objc func sendLogs() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error accessing AppDelegate")
            return
        }
        appDelegate.containerVc?.startLoadingAnimation()
        
        PingOne.sendLogs { (supportId, error) in
            if let supportId = supportId{
                print("Support ID:\(supportId)")
                Defaults.setSupportID(idStr: supportId)
                
                DispatchQueue.main.async{
                    appDelegate.containerVc?.stopLoadingAnimation()
                    
                    let alert = UIAlertController(title: "send_logs_title".localized, message: "send_logs_msg".localized, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: { (action) in
                    }))
                    self.present(alert, animated: true, completion: nil)
                    self.ticketIdLbl.text = "Support ID: \(supportId)"
                }
            }
            else if let error = error{
                print("error sending logs: \(error.debugDescription)")
            }
        }
    }
}
