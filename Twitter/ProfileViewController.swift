//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/25/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileBackgroundImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var tweetsCountLabel: UILabel!
    
    var user: User? {
        didSet {
            self.view.layoutIfNeeded()
            self.setDataAsProperty()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.user == nil {
            self.user = State.currentUser
            self.setDataAsProperty()
        }
        
        self.profileImage.layer.cornerRadius = 10
        self.profileImage.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    
    // --------------------------------------
    
    @IBAction func onXTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // --------------------------------------
    
    private func setDataAsProperty() {

        if let data = self.user {
            
            if let userName = data.name as? String {
                self.profileName.text = userName
            }

            if let screenName = data.screenName as? String {
                self.screenNameLabel.text = "@" + screenName
            }
            
            if let tweets = data.tweets {
                self.tweetsCountLabel.text = String(tweets)
            }
            
            if let followers = data.followers {
                self.followersCountLabel.text = String(followers)
            }
            
            if let following = data.following {
                self.followingCountLabel.text = String(following)
            }
            
            if let userImageURL = data.profileImageURL {
                ImageLoader.loadImage(
                    userImageURL,
                    imageview: self.profileImage,
                    success: nil,
                    failure: nil
                )
            }
            
            if let bannerImage = data.backgroundImage {
                ImageLoader.loadImage(
                    bannerImage,
                    imageview: self.profileBackgroundImage,
                    success: nil,
                    failure: nil
                    
                )
            } else {
                self.profileBackgroundImage.image = UIImage(named: "bg")
            }
        }
    }


    @IBAction func onHamburgerToggle(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(HAMBURGER_TOGGLE_EVENT, object: nil)
    }
}
