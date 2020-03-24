//
//  SideMenuVC.swift
//  Authenticator
//
//  Created by Amit Nadir on 26/01/2020.
//  Copyright © 2020 Ping Identity. All rights reserved.
//

import UIKit

class SideMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum MenuTag: String {
        case sendLogs = "send_logs"
    }

    private let cellIdentifier = "MenuTableViewCell"
    private var menuItems = [MenuTag.sendLogs]
    
    @IBOutlet var menuTableView: UITableView! {
        didSet {
            let cell = UINib(nibName: cellIdentifier, bundle: nil)
            menuTableView.register(cell, forCellReuseIdentifier: cellIdentifier)
            menuTableView.delegate = self
            menuTableView.dataSource = self
            menuTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            menuTableView.isScrollEnabled = false
            menuTableView.reloadData()
        }
    }
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var upperViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var versionLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Start listening to side menu open/close post notificaitons
        NotificationCenter.default.addObserver(self,selector: #selector(sideMenuWasToggled), name: NSNotification.Name("ToggleSideMenu"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(sideMenuWasToggleEnded), name: NSNotification.Name("ToggleSideMenuEnded"), object: nil)
        
        setupHeader()
        setupVersionLabel()
    }
    
    func setupHeader(){
        let navBar: NavBar = UIView.fromNib()
        upperView.frame = navBar.frame
        upperView.backgroundColor = .white
        upperViewHeightConstraint.constant = UIDevice.isIphoneX ? navBar.frame.height: navBar.frame.height + 17
        self.view.setNeedsLayout()
    }
    
    func setupVersionLabel(){
        versionLbl.textColor = UIColor.lightGray
        versionLbl.font = UIFont.systemFont(ofSize: 12.0)
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "0"
        
        versionLbl.text = "v\(version) (\(build))"
    }
    
    //MARK: Tableview Delegete methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MenuTableViewCell
        switch indexPath.row {
        case 0:
            cell.menuNameLbl.text = MenuTag.sendLogs.rawValue.localized
        default:
            cell.menuNameLbl.text = MenuTag.sendLogs.rawValue.localized
        }
        return cell
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        
        switch indexPath.row {
            case 0: NotificationCenter.default.post(name: NSNotification.Name("sendLogs"), object: nil)
        default: break
        }
    }
    
    //MARK: Handle shadow layer
    
    @objc func sideMenuWasToggled(){
        dropShadowForSideMenu()
    }

    func dropShadowForSideMenu() {
        let offSet: CGFloat = 2.0
        self.view.layer.masksToBounds = false
        self.view.layer.shadowColor = UIColor.gray.cgColor
        self.view.layer.shadowOpacity = 0.35
        self.view.layer.shadowOffset = CGSize(width: -offSet, height: 1)
        self.view.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.view.bounds.size.width + offSet*2, height: self.view.bounds.size.height)).cgPath
        self.view.layer.shouldRasterize = true
        self.view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    @objc func sideMenuWasToggleEnded() {
        self.view.layer.shadowColor = UIColor.clear.cgColor
    }
    
}
