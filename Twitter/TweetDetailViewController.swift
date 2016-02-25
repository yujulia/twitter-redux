//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/23/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

@objc protocol TweetDetailViewControllerDelegate {
    optional func tweetDetailViewController(tweetDetailViewController: TweetDetailViewController, didRetweet value: Tweet)
}

class TweetDetailViewController: UIViewController {
    

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tweetName: UILabel!
    @IBOutlet weak var tweetScreenName: UILabel!
    @IBOutlet weak var tweetTime: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var retweetIcon: UIImageView!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var retweetTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var favoriteCount: UILabel!
    
    weak var delegate: TweetDetailViewControllerDelegate?
    
    var data: Tweet?
    
    var favorited = false
    var retweeted = false

    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideRetweeted()
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        self.setDataAsProperty()
    }
    
    // --------------------------------------
    
    private func setDataAsProperty() {
        if let tweetText = self.data?.text {
            self.tweetTextLabel.text = tweetText as String
        }
        if let imageURL = self.data?.profileImageURL {
            self.loadProfileImage(imageURL)
        }
        if let tweetName = self.data?.name {
            self.tweetName.text = tweetName as String
        }
        if let screenName = self.data?.screenName {
            self.tweetScreenName.text = "@\(screenName as String)"
        }
        if let timestamp = self.data?.timestamp {
            let now = NSDate()
            let diff = now.timeIntervalSinceDate(timestamp)
            let timeago = NSDate(timeIntervalSinceNow: diff).timeAgoInWords()
            self.tweetTime.text = timeago
        }
        self.setRetweetsCount()
        self.setFavoritesCount()
        if let retweeted = self.data?.retweeted {
            if retweeted {
                if let userName = State.currentUser?.screenName {
                    showRetweeted(String(userName))
                }
                self.retweetButton.selected = true
                self.retweeted = true
            } else {
                self.retweetButton.selected = false
                self.retweeted = false
            }
        }
        if let favorited = self.data?.favorited {
            if favorited {
                self.favoriteButton.selected = true
                self.favorited = true
            } else {
                self.favoriteButton.selected = false
                self.favorited = false
            }
        }
    }
    
    // --------------------------------------
    
    func hideRetweeted() {
        self.retweetIcon.hidden = true
        self.retweetLabel.hidden = true
        self.retweetTopConstraint.constant = 0
        self.retweetLabel.text = ""
    }
    
    func showRetweeted(retweetedBy: String) {
        self.retweetIcon.hidden = false
        self.retweetLabel.hidden = false
        self.retweetTopConstraint.constant = 10
        self.retweetLabel.text = "\(retweetedBy) Retweeted"
    }
    
    // --------------------------------------
    
    func loadProfileImage(profileImageURL: NSURL) {
        self.profileImage.alpha = 0
        
        ImageLoader.loadImage(
            profileImageURL,
            imageview: self.profileImage,
            success: { () -> () in
                UIView.animateWithDuration(0.3,
                    animations:  {() in
                        self.profileImage.alpha = 1
                    }
                )
            },
            failure: { (error: NSError) -> () in
                self.profileImage.image = UIImage(named: "default")
                print("image load failure for profileImageURL: ", error.localizedDescription)
                self.profileImage.alpha = 1
            }
        )
    }
    
    // --------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ReplySegue" {
            let composeViewController = segue.destinationViewController as! ComposeViewController
            composeViewController.replyToTweet = self.data
        }
    }
    
    // -------------------------------------- update the counts
    
    private func setFavoritesCount() {
        if let favcount = self.data?.favorites {
            self.favoriteCount.text = String(favcount)
        }
    }
    
    private func setRetweetsCount() {
        if let recount = self.data?.retweets {
            self.retweetCount.text = String(recount)
        }
    }
    
    // -------------------------------------- retweet

    @IBAction func onRetweet(sender: AnyObject) {
        if self.retweeted {
            
            TwitterClient.sharedInstance.unRetweet(
                Int(self.data!.id!),
                success: { (returnedTweet: Tweet) -> () in
                    print("un retweet returned", returnedTweet)
                    self.retweetButton.selected = false
                    self.retweeted = false
                    self.data?.retweets--
                    self.setRetweetsCount()
            })
            
        } else {
            
            TwitterClient.sharedInstance.retweet(
                Int(self.data!.id!),
                success: { (returnedTweet: Tweet) -> () in

                    print("retweet returned", returnedTweet)
                    self.retweetButton.selected = true
                    self.retweeted = true
                    self.data?.retweets++
                    self.delegate?.tweetDetailViewController?(self, didRetweet: returnedTweet)
                    self.setRetweetsCount()
            })
        }
        
    }
    
    // -------------------------------------- favorite
    
    @IBAction func onFavorite(sender: AnyObject) {
        if self.favorited {
            
            TwitterClient.sharedInstance.removeFavorite(
                Int(self.data!.id!),
                success: { () -> () in
                    self.favoriteButton.selected = false
                    self.favorited = false
                    self.data?.favorites--
                    self.setFavoritesCount()
            })

        } else {
            
            TwitterClient.sharedInstance.addFavorite(
                Int(self.data!.id!),
                success: { () -> () in
                    self.favoriteButton.selected = true
                    self.favorited = true
                    self.data?.favorites++
                    self.setFavoritesCount()
            })
            
        }
        
    }
    
    // --------------------------------------

    @IBAction func onReply(sender: AnyObject) {
        self.performSegueWithIdentifier("ReplySegue", sender: nil)
    }
}
