//
//  State.swift
//  Twitter
//
//  Created by Julia Yu on 2/24/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import Foundation
import UIKit

private let CURRENT_USER_KEY: String = "currentUser"
private let USERS_KEY: String = "users"


class State: NSObject {
    
    static var _currentUser: User?
    static var users: [User] = []
    
    static var currentTweet: Tweet?
    static var timelineTweets: [Tweet]?
    static var lastBatchCount: Int = 0
    static var currentHomeTweetCount: Int = 0
    
    static var storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    static var store = NSUserDefaults.standardUserDefaults()
    
    // -------------------------------------- add a new user if we havent seen them before
    
    class func addUser(newUser: User) {
        
        var flag = true
        for existingUser in self.users {
            // we already added this user
            if newUser.screenName == existingUser.screenName {
                flag = false
            }
        }
        
        if flag {
            self.users.append(newUser)
            self.storeUsers()
        }

    }
    
    // -------------------------------------- copy current users to userdefaults
    
    class func storeUsers() {
        var storeArray: [NSDictionary] = []
        
        for aUser in self.users {
            if let data = aUser.userData {
                storeArray.append(data)
            }
        }
        
        let userDataJSON = try! NSJSONSerialization.dataWithJSONObject(storeArray, options: [])
        
        store.setObject(userDataJSON, forKey: USERS_KEY)
        store.synchronize()
    }
    
    // -------------------------------------- get users out of user defaults
    
    class func getUsersFromStore() {
        
        if let usersJSON = store.objectForKey(USERS_KEY) as? NSData {
            let usersArray = try! NSJSONSerialization.JSONObjectWithData(usersJSON, options: []) as! NSArray
            for existingUser in usersArray {
                let userObj = User(userData: existingUser as! NSDictionary)
                self.users.append(userObj)
                print("got from user store", userObj.screenName)
            }
        }
        
        print("got from user store", self.users.count)
        
    }
    
    class var window: UIWindow? {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let window = appDelegate.window!
            return window
        }
    }
    
    // -------------------------------------- get and set currentUser of the app
    
    class var currentUser: User? {
        get {
            // no user cached, search the store
        
            if self._currentUser == nil {
            
            let store = NSUserDefaults.standardUserDefaults()
            let userDataJSON = store.objectForKey(CURRENT_USER_KEY) as? NSData
            
            if let userDataJSON = userDataJSON {
                let userDataDictionary = try! NSJSONSerialization.JSONObjectWithData(userDataJSON, options: []) as! NSDictionary
                let user = User(userData: userDataDictionary)
                self._currentUser = user
            } else {
                return nil // no user
                }
            }
            return self._currentUser
        }
        
        // set the user
        
        set(user) {
            if let user = user {
                let userDataJSON = try! NSJSONSerialization.dataWithJSONObject(user.userData!, options: [])
                self.store.setObject(userDataJSON, forKey: CURRENT_USER_KEY)
                self._currentUser = user
            } else {
                self.store.setObject(nil, forKey: CURRENT_USER_KEY)
            }
            self.store.synchronize()
        }
    }
    
}