//
//  AlertBanner.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

class AlertBanner{
    
    enum AlertTag: NSInteger {
        case noPush = 100
        case noConnectivity
    }
    
    static func persistent(navBar: NavBar, title: String, animate: Bool, tag: AlertTag){
        if navBar.viewWithTag(tag.rawValue) != nil{ 
            return
        }
        else{
            let banner = AlertBanner.create(navBar: navBar, title: title)
            banner.tag = tag.rawValue
            banner.backgroundColor = .customDarkGrey
            navBar.insertSubview(banner, belowSubview: navBar.mainView)
            if animate{
               AlertBanner.animateShow(banner, isPersistent: true)
            }
            else{
                DispatchQueue.main.async{
                  show(banner)
                }
            }
        }
    }
    
    static func hidePersistent(_ tag: AlertTag, navBar: NavBar){
        if let banner = navBar.viewWithTag(tag.rawValue) as? UILabel{
            animateHide(banner, delay:0)
        }
    }
    
    static private func create(navBar: NavBar, title: String) -> UILabel{
        let height = UIDevice.isIphoneX ? navBar.frame.size.height * 0.50 : navBar.frame.size.height * 0.80
        let banner = UILabel.init(frame: CGRect(x: 0, y: navBar.frame.size.height - height, width: UIScreen.main.bounds.size.width, height: height))
        banner.numberOfLines = 2
        banner.text = title
        banner.textAlignment = .center
        banner.textColor = .white
        banner.font = UIFont.systemFont(ofSize: 16.0)
        return banner
    }
    
    static private func animateShow(_ banner: UILabel, isPersistent: Bool){
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            show(banner)
        }, completion: { finished in
            if !isPersistent{
                animateHide(banner, delay:1.5)
            }
        })
    }

    static private func animateHide(_ banner: UILabel, delay: Double){
        UIView.animate(withDuration: 0.3, delay: delay, options: [.curveEaseOut], animations: {
            hide(banner)
        }, completion: { finished in
            banner.removeFromSuperview()
        })
    }
    
    static private func show(_ banner: UILabel){
        banner.frame.origin.y = banner.frame.size.height + banner.frame.origin.y
    }
    
    static private func hide(_ banner: UILabel){
        banner.frame.origin.y = banner.frame.origin.y - banner.frame.size.height
    }
}
