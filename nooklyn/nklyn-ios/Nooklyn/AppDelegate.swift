//
//  AppDelegate.swift
//  Nooklyn
//
//  Created by Joe Gallo on 5/28/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deviceToken: String?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        clearUserDefaults()
        
        // do one time clear for 1.4.3 (post remove-realm)
        if !didOneTimeClear() {
            clearUserDefaults()
            CacheManager.removeLoggedInAgent()
            setDidOneTimeClear(true)
        }
        
        // load data from disk
        CacheManager.loadLoggedInAgentFromDisk()
        
        // get neighborhoods
        ApiManager.getNeighborhoods() { neighborhoods in
            // cache neighborhoods
            CacheManager.saveNeighborhoods(neighborhoods)
            
            // cache regions
            let regions = Array(Set(neighborhoods.map({ $0.region })))
            CacheManager.saveRegions(regions)
        }
        
        // register for remote notifications
        registerForRemoteNotifications(application)
        
        // google analytics
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
//        GAI.sharedInstance().logger.logLevel = GAILogLevel.Verbose
        
        // fabric
        Fabric.with([Crashlytics.self()])
        
        // if not first time, skip to listings view
        if alreadyLaunchedOnce() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("TabBar") 
            window?.rootViewController = vc
        } else {
            setAlreadyLaunchedOnce(true)
        }
        
        let facebookAppDidFinishLaunching = FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return facebookAppDidFinishLaunching
    }
    
    // MARK: - Remote notifications
    
    func registerForRemoteNotifications(application: UIApplication) {
        let types: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenString = (deviceToken.description as NSString) as String
        self.deviceToken = deviceTokenString
        ApiManager.updateDeviceToken(deviceTokenString)
        print(self.deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        // set messages tab badge value
        if let tabBarVC = window!.rootViewController as? CustomTabBarController {
            if tabBarVC.selectedIndex != 3 {
                (tabBarVC.viewControllers![3]).tabBarItem.badgeValue = "1"
            }
        }
    }
    
    // MARK: - Facebook open url
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            openURL: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }

    // MARK: - Application state events
    
    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // clear app badge number
        if UIApplication.sharedApplication().applicationIconBadgeNumber != 0 {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
        
        // Allow Facebook to capture events within your application including Ads clicked on from
        // Facebook to track downloads from Facebook and events like how many times your app was opened.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
    }
}

