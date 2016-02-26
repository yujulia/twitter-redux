//
//  LoginViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/22/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
    
    let client = TwitterClient.sharedInstance
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    var window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // --------------------------------------

    @IBAction func loginTapped(sender: AnyObject) {
        self.client.login({ (response: String) -> () in
            self.performSegueWithIdentifier("logInSegue", sender: nil)
        }) { (error: NSError) -> () in
            print("login failure: ", error.localizedDescription)
        }
    }
    
}
