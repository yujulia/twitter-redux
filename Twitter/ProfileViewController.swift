//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/25/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onHamburgerToggle(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(HAMBURGER_TOGGLE_EVENT, object: nil)
    }
}
