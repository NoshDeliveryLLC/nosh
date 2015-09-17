//
//  AppDelegate.swift
//  Nosh
//
//  Created by Muhammad Javeed on 18/01/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics()])
        Parse.enableLocalDatastore();
        Parse.setApplicationId(Config.Parse.appId, clientKey:Config.Parse.clientId)
        GMSServices.provideAPIKey("AIzaSyDplreFQyvs_lih-pqcr3vCbi5c9yokv80")
        
        let config = PFConfig.currentConfig()
        if(config != nil && config["stripe"] != nil && config["gms_key"] != nil){
            Util.configure(config)
            PFConfig.getConfigInBackgroundWithBlock{
                (config: PFConfig!, error: NSError!) -> Void in
                if(config != nil){
                    Util.configure(config, gms: false)
                }
            }
        }
        
        let userNotificationTypes = (UIUserNotificationType.Alert |  UIUserNotificationType.Badge |  UIUserNotificationType.Sound);
        
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        let query = PFUser.query()
        query.fromLocalDatastore()
        query.fromPinWithName("lastUser")
        var lastUser: PFUser = PFUser.new()
        var findresult: Bool = false
        query.getFirstObjectInBackgroundWithBlock { (object:PFObject!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                lastUser = object as! PFUser
                findresult = true
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }}
    
        if (PFUser.currentUser() == nil){
            if (findresult) {
                PFUser.logInWithUsername(lastUser.username, password: lastUser.password)
                lastUser.unpin()
            } else {
            gotoLogin()
            }
        }
        
        // Extract the notification data
        if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            let option = notificationPayload["option"] as? NSString
            if option == "2"{
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initViewController: MyOrdersVC = storyboard.instantiateViewControllerWithIdentifier("MyOrders") as! MyOrdersVC
                self.window?.rootViewController = initViewController
            }
        }

        return true
    }
        
    func gotoLogin(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initViewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier("login") as! UIViewController
        initViewController.title = "login"
        initViewController.navigationController?.navigationBarHidden = true
        self.window?.rootViewController = initViewController
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.save()
    }
    
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let option = userInfo["option"] as? NSString
        if option == "2"{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initViewController: MyOrdersVC = storyboard.instantiateViewControllerWithIdentifier("MyOrders") as! MyOrdersVC
            self.window?.rootViewController?.navigationController?.pushViewController(initViewController, animated: true)
            completionHandler(UIBackgroundFetchResult.NewData)
        }
         completionHandler(UIBackgroundFetchResult.NoData)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

