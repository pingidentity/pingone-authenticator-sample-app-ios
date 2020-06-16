//
//  AppDelegate.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit
import UserNotifications
import PingOne

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var notificationObject: NotificationObject?
    var containerVc: ContainerVC?
    var navigationVc: NavigationController?
    var isKeyboardVisible = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            window!.overrideUserInterfaceStyle = .light
        }

        if Defaults.getNotificationPermissionCounter() > 0 { //For first app load we register on notification screen
            
            let center  = UNUserNotificationCenter.current()
                center.getNotificationSettings(completionHandler: { settings in
                    if settings.authorizationStatus == .authorized {
                        self.registerRemoteNotifications()
                    }
                })
        }
    
        if let containerVc = self.window?.rootViewController as? ContainerVC{
            self.containerVc = containerVc
        }
        
        return true
    }
    
    func registerRemoteNotifications(completionHandler: (() -> Void)? = nil){
    print("Registering remote notifications")
        
        let center  = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            completionHandler?()
            if error == nil
            {
                // Registering UNNotificationCategories more than once results in previous categories being overwritten. PingOne provides the needed categories. The developer may add categories.
                UNUserNotificationCenter.current().setNotificationCategories(PingOne.getUNNotificationCategories())
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(deviceTokenString)")

        var deviceTokenType : PingOne.APNSDeviceTokenType = .production
        #if DEBUG
        deviceTokenType = .sandbox
        #endif
        
        PingOne.setDeviceToken(deviceToken, type: deviceTokenType) { (error) in
            if let error = error{
                print(error.localizedDescription)
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        print("didReceive")
        
        PingOne.processRemoteNotificationAction(response.actionIdentifier, authenticationMethod: "user", forRemoteNotification: response.notification.request.content.userInfo) { (notificationObject, error) in
            
            if let error = error{
                print("Error: \(String(describing: error))")
                if error.code == ErrorCode.unrecognizedRemoteNotification.rawValue{
                    //Do something else with remote notification.
                }
            }
            else if let notificationObject = notificationObject{ //User pressed the actual banner, instead of an action.
                if let userInfo = response.notification.request.content.userInfo as? [String : Any] {
                    let title = self.getNotificationTextFrom(userInfo).title
                    let message = self.getNotificationTextFrom(userInfo).body
                    self.displayNotificationViewAlert(notificationObject, title: title, message: message)
                }
            }
            completionHandler()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        print("didReceiveRemoteNotification userinfo: \(userInfo)")
        
        PingOne.processRemoteNotification(userInfo) { (notificationObject, error) in
            if let error = error{
                print("Error: \(String(describing: error))")
                if error.code == ErrorCode.unrecognizedRemoteNotification.rawValue{
                    //Unrecognized remote notification.
                    completionHandler(UIBackgroundFetchResult.noData)
                }
            }
            else if let notificationObject = notificationObject{
                switch(notificationObject.notificationType){
                case .authentication:
                    
                    if let userInfo = userInfo as? [String : Any] {
                        let title = self.getNotificationTextFrom(userInfo).title
                        let message = self.getNotificationTextFrom(userInfo).body
                        self.displayNotificationViewAlert(notificationObject, title: title, message: message)
                        completionHandler(UIBackgroundFetchResult.newData)
                    }

                default:
                    print("Error: \(String(describing: error))")
                    completionHandler(UIBackgroundFetchResult.noData)
                }
            }
            else{
                completionHandler(UIBackgroundFetchResult.noData)
            }
        }
    }
    
    func displayNotificationViewAlert(_ notificationObject: NotificationObject, title: String?, message: String?){
        if self.notificationObject == nil {
            self.notificationObject = notificationObject

            DispatchQueue.main.async {
                if let authController = UIStoryboard(name: DefaultsKeys.storyboardKey, bundle: nil).instantiateViewController(withIdentifier: ViewControllerKeys.AuthVcID) as? AuthenticationViewController, let navVc = self.navigationVc {
                    authController.notificationObject = notificationObject
                    authController.pushTitle = title
                    authController.pushMessage = message
                    authController.modalPresentationStyle = .overCurrentContext
                    navVc.topViewController?.present(authController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func getNotificationTextFrom(_ userInfo: [String: Any]) -> (title: String, body: String){
        
        if let aps = userInfo[Push.aps] as? [String:Any] {
            if let alert = aps[Push.alert] as? [String:String] {
                if let title = alert[Push.title], let body = alert[Push.body] {
                     return (title,body)
                }
            }
        }
        return ("","")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

