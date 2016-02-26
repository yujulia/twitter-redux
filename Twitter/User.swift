//
//  User.swift
//  Twitter
//
//  Created by Julia Yu on 2/22/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: NSString?
    var screenName: NSString?
    var tagline: NSString?
    var profileImageURL: NSURL?
    var userData: NSDictionary?
    var favorites: Int?
    var followers: Int?
    var following: Int? // this is friends i guess?
    var tweets: Int?
    var backgroundImage: NSURL? // this is the banner
    
    // -------------------------------------- 
    
    init(userData: NSDictionary) {
        
        self.userData = userData
        self.name = userData["name"] as? String
        self.screenName = userData["screen_name"] as? String
        self.tagline = userData["description"] as? String
        self.favorites = userData["favourites_count"] as? Int
        self.followers = userData["followers_count"] as? Int
        self.following = userData["friends_count"] as? Int
        self.tweets = userData["statuses_count"] as? Int
        
        let profileImageURLStr = userData["profile_image_url_https"] as? String
        if let profileImageURL = profileImageURLStr {
            // replace the last bit
            
            let replacedURL = profileImageURL.stringByReplacingOccurrencesOfString("normal.jpeg", withString: "400x400.jpeg")
            
            self.profileImageURL = NSURL(string: replacedURL)
        }
        
        let bannerURLStr = userData["profile_banner_url"] as? String
        if let bannerURL = bannerURLStr {
            self.backgroundImage = NSURL(string: bannerURL)
        }
    }
    
}
