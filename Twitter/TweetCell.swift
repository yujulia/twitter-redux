//
//  TweetCell.swift
//  Twitter
//
//  Created by Julia Yu on 2/22/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit
import TimeAgoInWords

let railsStrings = [
    "LessThan": "less than ",
    "About": "",
    "Over": "",
    "Almost": "",
    "Seconds": " seconds",
    "Minute": " minute",
    "Minutes": " minutes",
    "Hour": " hour",
    "Hours": " hours",
    "Day": " day",
    "Days": " days",
    "Months": " months",
    "Years": " years",
]

@objc protocol TweetCellDelegate {
    optional func tweetCell(tweetCell: TweetCell, didWantToReply value: TweetCell)
    
    optional func tweetCell(tweetCell: TweetCell, didWantToShowProfile value: User)
}

class TweetCell: UITableViewCell {

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
    
    let client = TwitterClient.sharedInstance
    
    weak var delegate: TweetCellDelegate?
    
    var data: Tweet? {
        didSet {
            self.setDataAsProperty()
        }
    }
    var favorited: Bool = false
    var retweeted: Bool = false

    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.hideRetweeted()
        TimeAgoInWordsStrings.updateStrings(railsStrings)
    }
    
    // -------------------------------------- put the data in our view
    
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
                self.hideRetweeted()
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
    
    private func hideRetweeted() {
        self.retweetIcon.hidden = true
        self.retweetLabel.hidden = true
        self.retweetTopConstraint.constant = 0
        self.retweetLabel.text = ""
    }
    
    private func showRetweeted(retweetedBy: String) {
        self.retweetIcon.hidden = false
        self.retweetLabel.hidden = false
        self.retweetTopConstraint.constant = 10
        self.retweetLabel.text = "\(retweetedBy) Retweeted"
    }
    
    // -------------------------------------- load profile image
    
    private func loadProfileImage(profileImageURL: NSURL) {
        self.profileImage.alpha = 0
        
        ImageLoader.loadImage(
            profileImageURL,
            imageview: self.profileImage,
            success: { () -> () in
                self.onProfileImageLoaded()
            },
            failure: { (error: NSError) -> () in
                self.onProfileImageErred(error.localizedDescription)
            }
        )
    }
    
    private func onProfileImageErred(error: String) {
        print("image load failure for profileImageURL: ", error)
        self.profileImage.image = UIImage(named: "default")
        self.profileImage.alpha = 1
    }
    
    private func onProfileImageLoaded() {
        UIView.animateWithDuration(0.3,
            animations:  {() in
                self.profileImage.alpha = 1
                let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onProfileImageTap:")
                self.profileImage.addGestureRecognizer(imageTapGestureRecognizer)
            }
        )
    }
    
     // --------------------------------------
    
    func onProfileImageTap(sender: UITapGestureRecognizer) {
        let state = sender.state
        if state == UIGestureRecognizerState.Ended {
            self.delegate?.tweetCell?(self, didWantToShowProfile: self.data!.user!)
        }
    }
    
    // --------------------------------------

    @IBAction func onRetweet(sender: AnyObject) {
        if self.retweeted {
            
            client.unRetweet(
                self.data!.id!,
                success: { (returnedTweet: Tweet) -> () in
                    print("un retweet returned", returnedTweet)
                    self.retweetButton.selected = false
                    self.retweeted = false
            })
            
        } else {
            client.retweet(
                self.data!.id!,
                success: { (returnedTweet: Tweet) -> () in
                    self.retweetButton.selected = true
                    self.retweeted = true
            })
        }
    }
    
    // --------------------------------------

    @IBAction func onFavorite(sender: AnyObject) {
        if self.favorited {
            client.removeFavorite(
                self.data!.id!,
                success: { () -> () in
                    self.favoriteButton.selected = false
                    self.favorited = false
                    self.data?.favorites--
            })
        } else {
            client.addFavorite(
                self.data!.id!,
                success: { () -> () in
                    self.favoriteButton.selected = true
                    self.favorited = true
                    self.data?.favorites++
            })
        }
    }
    
    // --------------------------------------
    
    @IBAction func onReply(sender: AnyObject) {
        self.delegate?.tweetCell?(self, didWantToReply: self)
    }
}
