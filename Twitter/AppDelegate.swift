//
//  AppDelegate.swift
//  Twitter
//
//  Created by Julia Yu on 2/22/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // --------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print("app launch")
        
        State.getUsersFromStore()
        
        if State.currentUser != nil {
            print("user already logged in")
            self.setRootAsHamburger()
        } else {
            print("user not logged in")
        }
        
        self.ObserveUserLogout()
        
        return true
    }
    
    // --------------------------------------
    
    private func ObserveUserLogout() {
        NSNotificationCenter.defaultCenter().addObserverForName(LOGOUT_EVENT, object: nil, queue: NSOperationQueue.mainQueue()) { (note: NSNotification) -> Void in
            print("user wants to log out")
            self.logOutUser()
        }
    }
    
    // --------------------------------------
    
    private func logOutUser() {
        let LoginViewController = State.storyBoard.instantiateInitialViewController()
        
        UIView.transitionWithView(
            self.window!,
            duration: 0.5,
            options: UIViewAnimationOptions.TransitionFlipFromLeft,
            animations: { () -> Void in
                self.window?.rootViewController = LoginViewController
            }, completion: nil)
    }
    
    // --------------------------------------
    
    private func setRootAsHamburger() {
        let hamburgerViewController = State.storyBoard.instantiateViewControllerWithIdentifier("HamburgerView")
        self.window?.rootViewController = hamburgerViewController
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

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        print("open url called")
        TwitterClient.sharedInstance.handleOpenURL(url)
        return true
    }

}

