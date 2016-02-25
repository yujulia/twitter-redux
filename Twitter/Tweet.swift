//
//  Tweet.swift
//  Twitter
//
//  Created by Julia Yu on 2/22/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var name: NSString?
    var screenName: NSString?
    var text: NSString?
    var timestamp: NSDate?
    var retweets: Int = 0
    var favorites: Int = 0
    var profileImageURL: NSURL?
    var retweeted: Bool?
    var favorited: Bool?
    var id: NSNumber?
    
    // -------------------------------------- 
    
    init(tweetData: NSDictionary) {
        
        self.text = tweetData["text"] as? String
        self.retweets = (tweetData["retweet_count"] as? Int) ?? 0
        self.favorites = (tweetData["favorite_count"] as? Int) ?? 0
        self.name = tweetData.valueForKeyPath("user.name") as? String
        self.screenName = tweetData.valueForKeyPath("user.screen_name") as? String
        self.retweeted = tweetData["retweeted"] as? Bool ?? false
        self.favorited = tweetData["favorited"] as? Bool ?? false
        self.id = tweetData["id"] as? NSNumber ?? 0
        
        if let timestampStr = tweetData["created_at"] as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            self.timestamp = dateFormatter.dateFromString(timestampStr)
        }
        
        let profileImageURLStr = tweetData.valueForKeyPath("user.profile_image_url_https") as? String
        if let profileImageURL = profileImageURLStr {
            self.profileImageURL = NSURL(string: profileImageURL)
        }
    }
    
    // --------------------------------------
    
    class func tweetsWithArray(tweetsArray: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for tweetData in tweetsArray {
            let tweet = Tweet(tweetData: tweetData)
            tweets.append(tweet)
        }
        
        return tweets
    }
}
