//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/23/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

@objc protocol ComposeViewControllerDelegate {
    optional func composeViewController(composeViewController: ComposeViewController, didTweet value: Tweet)
}

class ComposeViewController: UIViewController {

    @IBOutlet weak var composeBtn: UIButton!
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var charCount: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    let client = TwitterClient.sharedInstance
    let textBoxPlaceholder = "What's Happening?"
    
    weak var delegate: ComposeViewControllerDelegate?
    weak var replyToTweet: Tweet?
    var replying = false
    
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.composeBtn.enabled = false
        self.loadProfileImage(State.currentUser!.profileImageURL!)
        self.textBox.delegate = self
        self.charCount.text = "0"
        self.textBox.text = self.textBoxPlaceholder
        self.setupReply()
    }
    
    // --------------------------------------
    
    func setupReply() {
        if replyToTweet != nil {
            self.replying = true
            self.textBox.text = "@\(replyToTweet?.screenName as! String) "
        }
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
    
    @IBAction func onTweet(sender: AnyObject) {

        if !self.composeBtn.enabled {
            return
        }
        
        if self.replying {
            self.goingToReply()
        } else {
            self.goingToTweet()
        }
    }
    
    // --------------------------------------
    
    private func goingToTweet() {
        self.client.postNewTweet(
            self.textBox.text,
            success: { (tweet: Tweet) -> () in
                State.currentTweet = tweet
                self.delegate?.composeViewController?(self, didTweet: tweet)
                self.closeView()
            }) { (error: NSError) -> () in
                print("post tweet error: ", error.localizedDescription)
        }
    }
    
    // --------------------------------------
    
    private func goingToReply() {
        self.client.postReplyTweet(
            self.textBox.text,
            replyTweet: self.replyToTweet!,
            success: { (tweet: Tweet) -> () in
                State.currentTweet = tweet
                self.delegate?.composeViewController?(self, didTweet: tweet)
                self.closeView()
            }) { (error: NSError) -> () in
                print("post tweet error: ", error.localizedDescription)
        }
    }

    // --------------------------------------
    
    private func closeView() {
        self.textBox.text = ""
        self.composeBtn.enabled = false
        self.charCount.text = "0"
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // --------------------------------------

    @IBAction func xClick(sender: AnyObject) {
        self.closeView()
    }
}

extension ComposeViewController: UITextViewDelegate {
    
    // --------------------------------------
    
    func textViewDidChange(textView: UITextView) {
        
        let stringLength = textView.text.characters.count
        
        if (stringLength > 0) && (stringLength < 140) {
            self.composeBtn.enabled = true
            self.charCount.textColor = UIColor.darkGrayColor()
            self.charCount.text = String(stringLength)
        } else {
            self.composeBtn.enabled = false
        }
        
        if stringLength > 140 {
            self.charCount.textColor = UIColor.redColor()
            self.charCount.text = String(140 - stringLength)
        }
    }
    
    // --------------------------------------
    
    func textViewDidBeginEditing(textView: UITextView) {
        if self.textBox.text == self.textBoxPlaceholder {
            self.textBox.text = ""
        }
    }
}
