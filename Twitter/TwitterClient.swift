//
//  TwitterClient.swift
//  Twitter
//
//  Created by Julia Yu on 2/22/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let LOGOUT_EVENT = "UserDidLogout"

private let BASE_URL = "https://api.twitter.com"
private let CONSUMER_KEY = "tlQEQS7zcKp93aO8qfn3IOenH"
private let CONSUMER_SECRET = "Hd5SmNqUmE09LnysMqoTWE2JMogm5yxYERBZGsA2Xbe4BDEwnJ"
private let CALLBACK_URL = "twitterdemo://oauth"
private let AUTH_URL = "https://api.twitter.com/oauth/authorize?oauth_token="

private let ENDPOINT_REQUEST_TOKEN = "oauth/request_token"
private let ENDPOINT_ACCESS_TOKEN = "oauth/access_token"
private let ENDPOINT_VERIFY_CREDENTIALS = "1.1/account/verify_credentials.json"
private let ENDPOINT_HOME_TIMELINE = "1.1/statuses/home_timeline.json"
private let ENDPOINT_MENTIONS_TIMELINE = "/1.1/statuses/mentions_timeline.json"

class TwitterClient: BDBOAuth1SessionManager {
    
    enum Timelines: Int {
        case Nothing = 0
        case Home = 1
        case Mentions = 2
    }
    
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
        print("client login")
        
        self.loginSuccess = success
        self.loginFailure = failure
        
        self.deauthorize()
        self.fetchRequestTokenWithPath(
            ENDPOINT_REQUEST_TOKEN,
            method: "GET",
            callbackURL: NSURL(string: CALLBACK_URL),
            scope: nil,
            success: { (requestToken: BDBOAuth1Credential!) -> Void in
                print("client login got request token")
                let authString = AUTH_URL + requestToken.token
                if let authURL = NSURL(string: authString) {
                    UIApplication.sharedApplication().openURL(authURL)
                }
            
            }) { (error: NSError!) -> Void in
                print("client login failure", error.localizedDescription)
                self.loginFailure?(error)
        }
    }
    
    // ----------------------------------------- 
    
    func handleOpenURL(url: NSURL) {
        if let requestToken = BDBOAuth1Credential(queryString: url.query) {
            self.fetchAccessTokenWithPath(
                ENDPOINT_ACCESS_TOKEN,
                method: "POST",
                requestToken: requestToken,
                success: { (credentials: BDBOAuth1Credential!) -> Void in
                    
                    print("client got access token")
                    
                    self.verifyCredentials(
                        { (user: User) -> () in
                            print("client got credentials")
                            State.currentUser = user
                            self.loginSuccess?("ok")
                        },
                        failure: { (error: NSError) -> () in
                            print("client failed to get credentials")
                            self.loginFailure?(error)
                        }
                    )
                    
                }) { (error: NSError!) -> Void in
                    print("client access token get error", error.localizedDescription)
            }
        } else {
            print("client failed to make request token")
        }
    }
    
    // ----------------------------------------- 
    
    func verifyCredentials(success: (User) -> (), failure: (NSError) -> ()) {
        self.GET(
            ENDPOINT_VERIFY_CREDENTIALS,
            parameters: nil,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let userDictionary = response as? NSDictionary
                if let userDictionary = userDictionary {
                    let user = User(userData: userDictionary)
                    success(user)
                } else {
                    print("client failed to verify credentials unable to get user data")
                }
                
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        }
    }
    
    // ----------------------------------------- timeline
    
    func loadTimelineOfType(timeline: Timelines, last_id: String?, success: () -> (), failure: (NSError) -> ()) {
        
        // default to home timline
        var endpoint = ENDPOINT_HOME_TIMELINE
        if timeline == Timelines.Mentions {
            endpoint = ENDPOINT_MENTIONS_TIMELINE
        }
        
        // set params if any
        var params: [String: String]?
        if let id = last_id {
            params = ["max_id": id]
        }
        
        print("GET TIMELINE WITH params: ", params, "lastid: ", last_id, "endpoint", endpoint)

        self.GET(
            endpoint,
            parameters: params,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                print("GET returned ")
                if let allTweets = response as? [NSDictionary] {
                    var tweets = Tweet.tweetsWithArray(allTweets)
                    
                    // pop off the top result if this is load more
                    if State.currentHomeTweetCount > 0 {
                        tweets.removeAtIndex(0)
                    }
                    
                    State.lastBatchCount = tweets.count
                    
                    if last_id != nil {
                        State.timelineTweets?.appendContentsOf(tweets)
                    } else {
                        State.timelineTweets = tweets
                    }
                    
                    State.currentHomeTweetCount = State.timelineTweets?.count ?? 0
                    
                    success()
                }
            }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("GET failed ", error)
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
    
    func addFavorite(fave_id: String, success: ()->()) {
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
    
    func removeFavorite(fave_id: String, success: ()->()) {
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
    
    func retweet(retweet_id: String, success: (Tweet)->()) {
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
    
    func unRetweet(retweet_id: String, success: (Tweet)->()) {
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
