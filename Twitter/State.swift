//
//  State.swift
//  Twitter
//
//  Created by Julia Yu on 2/24/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import Foundation

private let CURRENT_USER_KEY: String = "currentUser"

class State: NSObject {
    
    static var _currentUser: User?
    static var currentTweet: Tweet?
    static var homeTweets: [Tweet]?
    static var lastBatchCount: Int = 0
    static var currentHomeTweetCount: Int = 0
    
    // -------------------------------------- get and set currentUser of the app
    
    class var currentUser: User? {
        get {
            // no user cached, search the store
        
            if _currentUser == nil {
            
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
            let store = NSUserDefaults.standardUserDefaults()
            
            if let user = user {
                let userDataJSON = try! NSJSONSerialization.dataWithJSONObject(user.userData!, options: [])
                store.setObject(userDataJSON, forKey: CURRENT_USER_KEY)
            } else {
                store.setObject(nil, forKey: CURRENT_USER_KEY)
            }
            store.synchronize()
        }
    }
    
}