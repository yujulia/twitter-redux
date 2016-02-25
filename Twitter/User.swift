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
    
    // -------------------------------------- 
    
    init(userData: NSDictionary) {
        
        self.userData = userData
        self.name = userData["name"] as? String
        self.screenName = userData["screen_name"] as? String
        self.tagline = userData["description"] as? String
        
        let profileImageURLStr = userData["profile_image_url"] as? String
        if let profileImageURL = profileImageURLStr {
            self.profileImageURL = NSURL(string: profileImageURL)
        }
    }
    
}
