//
//  AppDelegate.swift
//  Edge
//
//  Created by Isaiah Turner on 2/8/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//

import UIKit
import plaid_ios_link

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var client = EdgeAPIClient()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Plaid.sharedInstance().setPublicKey("db0c7fe8afdfac06b1997b0d4a1b96")
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds);
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        //UIViewController *viewController = f
        let defaults = NSUserDefaults.standardUserDefaults()
        let hasLaunched = defaults.objectForKey("hasLaunched")
        let _user = defaults.objectForKey("_user")
        let viewController:UIViewController!
        if ((hasLaunched == nil)) {
            defaults.setBool(true, forKey: "hasLaunched")
            viewController = storyboard.instantiateViewControllerWithIdentifier("onboarding")
        } else if ((_user) != nil) {
            viewController = storyboard.instantiateViewControllerWithIdentifier("connect")
            if let navVC = viewController as? UINavigationController {
                if let vc = navVC.topViewController as? ConnectViewController {
                    vc.client = self.client
                }
            }
        } else {
            viewController = storyboard.instantiateViewControllerWithIdentifier("auth")
        }
        
        self.window!.rootViewController = viewController;
        self.window?.makeKeyAndVisible()
        let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Register for Push Notifications on devices <= iOS 8
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
        
        return true
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
    
    private func convertDeviceTokenToString(deviceToken:NSData) -> String {
        //  Convert binary Device Token to a String (and remove the <,> and white space charaters).
        var deviceTokenStr = deviceToken.description.stringByReplacingOccurrencesOfString(">", withString: "", options: NSStringCompareOptions(), range: nil)
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString("<", withString: "", options: NSStringCompareOptions(), range: nil)
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions(), range: nil)
        
        // Our API returns token in all uppercase, regardless how it was originally sent.
        // To make the two consistent, I am uppercasing the token string here.
        deviceTokenStr = deviceTokenStr.uppercaseString
        return deviceTokenStr
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = convertDeviceTokenToString(deviceToken)
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()!
        var alert = false
        var badge = false
        var sound = false
        if settings.types.contains(.Alert) {
            alert = true
        }
        if settings.types.contains(.Badge) {
            badge = true
        }
        if settings.types.contains(.Sound) {
            sound = true
        }
        let appledevice = AppleDevice(token: token, alert: alert, badge: badge, sound: sound, deviceId: UIDevice.currentDevice().identifierForVendor!.UUIDString, transactionNotifications: true, allNotifications: true, owner: nil)
        appledevice.save { (response, data, appledevice, error) -> () in
            if ((error) != nil) {
                let alertController = UIAlertController(title: "Error", message:
                    error, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            } else {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setValue(appledevice?.id, forKey: "_appledevice")
                print("Subscribed for notifications! \(token)");
            }
        }
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Couldn't register: \(error)");
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        print("Updated Settings \(notificationSettings)")
        // inspect notificationSettings to see what the user said!
    }
}

