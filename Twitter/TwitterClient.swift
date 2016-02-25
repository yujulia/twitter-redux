//
//  TwitterClient.swift
//  Twitter
//
//  Created by Julia Yu on 2/22/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

private let BASE_URL = "https://api.twitter.com"
private let CONSUMER_KEY = "tlQEQS7zcKp93aO8qfn3IOenH"
private let CONSUMER_SECRET = "Hd5SmNqUmE09LnysMqoTWE2JMogm5yxYERBZGsA2Xbe4BDEwnJ"
private let LOGOUT_EVENT = "UserDidLogout"

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(
        baseURL: NSURL(string: BASE_URL)!,
        consumerKey: CONSUMER_KEY,
        consumerSecret: CONSUMER_SECRET
    )
    
    var loginSuccess: ((String) -> ())?
    var loginFailure: ((NSError) -> ())?
    
    // ----------------------------------------- logout
    
    func logout() {
        State.currentUser = nil
        self.deauthorize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(LOGOUT_EVENT, object: nil)
    }
    
    // ----------------------------------------- login
    
    func login(success: (String)->(), failure: (NSError) ->() ) {
        
        self.loginSuccess = success
        self.loginFailure = failure
        
        self.deauthorize()
        self.fetchRequestTokenWithPath(
            "oauth/request_token",
            method: "GET",
            callbackURL: NSURL(string: "twitterdemo://oauth"),
            scope: nil,
            success: { (requestToken: BDBOAuth1Credential!) -> Void in
            
                let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
                UIApplication.sharedApplication().openURL(authURL)
            
            }) { (error: NSError!) -> Void in
                self.loginFailure?(error)
        }
    }
    
    // ----------------------------------------- 
    
    func handleOpenURL(url: NSURL) {
        
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        self.fetchAccessTokenWithPath(
            "oauth/access_token",
            method: "POST",
            requestToken: requestToken,
            success: { (credentials: BDBOAuth1Credential!) -> Void in
                
                self.verifyCredentials(
                    { (user: User) -> () in
                        State.currentUser = user
                        self.loginSuccess?("ok")
                    },
                    failure: { (error: NSError) -> () in
                        self.loginFailure?(error)
                    }
                )   
                
            }) { (error: NSError!) -> Void in
                print(error.localizedDescription)
        }
    }
    
    // ----------------------------------------- 
    
    func verifyCredentials(success: (User) -> (), failure: (NSError) -> ()) {
        self.GET(
            "1.1/account/verify_credentials.json",
            parameters: nil,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let userDictionary = response as? NSDictionary
                if let userDictionary = userDictionary {
                    let user = User(userData: userDictionary)
                    success(user)
                } else {
                    print("Error verifying credentials: could not get user data from Twitter")
                }
                
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        }
    }
    
    // ----------------------------------------- load home timeline or load more
    
    func loadHomeTimeline(success: () -> (), failure: (NSError) -> ()) {
        self.getHomeTimeline(
            nil,
            success: { (response: AnyObject) -> () in
                if let allTweets = response as? [NSDictionary] {
                    let tweets = Tweet.tweetsWithArray(allTweets)
                    State.currentHomeTweetCount = tweets.count
                    State.lastBatchCount = tweets.count
                    State.homeTweets = tweets
                    success()
                }
            },
            failure: { (error: NSError) -> () in
                failure(error)
            }
        )
    }
    
    func loadMoreHomeTimeline(last_id: Int, success: () -> (), failure: (NSError) -> ()) {
        let nextMax = last_id - 1
        let params = ["max_id": nextMax]
        
        self.getHomeTimeline(
            params,
            success: { (response: AnyObject) -> () in
                if let allTweets = response as? [NSDictionary] {
                    let tweets = Tweet.tweetsWithArray(allTweets)
                    State.lastBatchCount = tweets.count
                    State.homeTweets?.appendContentsOf(tweets)
                    State.currentHomeTweetCount = (State.homeTweets?.count)!
                    
                    print("load more got", State.lastBatchCount, " total ", State.currentHomeTweetCount)
                    
                    success()
                }
            },
            failure: { (error: NSError) -> () in
                failure(error)
            }
        )
    }
    
    func getHomeTimeline(params: NSDictionary?, success: (AnyObject) -> (), failure: (NSError) -> ()) {
        self.GET(
            "1.1/statuses/home_timeline.json",
            parameters: params,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                success(response!)
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        }

    }
    
    // ----------------------------------------- post reply or new tweet
    
    func postReplyTweet(tweet: String, replyTweet: Tweet, success: (Tweet)->(), failure: (NSError) -> ()) {
        
        if let replyID = replyTweet.id {
            let tweetParam: NSDictionary = ["status" : tweet, "in_reply_to_status_id": replyID]
            self.tweet(tweetParam, success: success, failure: failure)
        } else {
            print("unable to find repy id")
        }
    }
    
    func postNewTweet(tweet: String, success: (Tweet)->(), failure: (NSError) -> ()) {
        let tweetParam: NSDictionary = ["status" : tweet]
        self.tweet(tweetParam, success: success, failure: failure)
    }
    
    func tweet(tweetParam: NSDictionary, success: (Tweet)->(), failure: (NSError) -> ()) {
        self.POST(
            "/1.1/statuses/update.json",
            parameters: tweetParam,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                if let tweetDict = response as? NSDictionary {
                    let tweetData = Tweet.init(tweetData: tweetDict)
                    success(tweetData)
                } else {
                    print("failed to get valid tweet response")
                }
                
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        }
    }
    
    // ----------------------------------------- favorite / remove favorite
    
    func addFavorite(fave_id: Int, success: ()->()) {
        let endpoint = "/1.1/favorites/create.json"
        
        let faveParams = ["id": fave_id]
        
        self.POST(
            endpoint,
            parameters: faveParams,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                
                success()
                
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("favorited got error", error.localizedDescription)
        }
    }
    
    func removeFavorite(fave_id: Int, success: ()->()) {
        let endpoint = "/1.1/favorites/destroy.json"
        
        let faveParams = ["id": fave_id]
        
        self.POST(
            endpoint,
            parameters: faveParams,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                success()
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("unfavorited got error", error.localizedDescription)
        }
    }
    
    // ----------------------------------------- retweet / unretweet
    
    func retweet(retweet_id: Int, success: (Tweet)->()) {
        let endpoint = "/1.1/statuses/retweet/\(retweet_id).json"
        let retweetParams = ["id": retweet_id]
        
        print("trying to retweet");
        
        self.POST(
            endpoint,
            parameters: retweetParams,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                
                if let tweetDict = response as? NSDictionary {
                    let tweetData = Tweet.init(tweetData: tweetDict)
                    success(tweetData)
                } else {
                    print("failed to get valid tweet response from retweet")
                }
                
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("retweet got error", error.localizedDescription)
        }
    }
    
    func unRetweet(retweet_id: Int, success: (Tweet)->()) {
        let endpoint = "/1.1/statuses/unretweet/\(retweet_id).json"
        let retweetParams = ["id": retweet_id]
        
        print("trying to unretweet");
        
        self.POST(
            endpoint,
            parameters: retweetParams,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                if let tweetDict = response as? NSDictionary {
                    let tweetData = Tweet.init(tweetData: tweetDict)
                    success(tweetData)
                } else {
                    print("failed to get valid tweet response from unretweet")
                }
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("unretweet got error", error.localizedDescription)
        }
    }
}
