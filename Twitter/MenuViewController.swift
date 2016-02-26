//
//  MenuViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/25/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let ESTIMATE_ROW_HEIGHT: CGFloat = 120.0
    
    private var MenuViewControllers: [UIViewController] = []
    private var ProfileNavController: UIViewController!
    private var TweetsNavController: UIViewController!
    
    private var MenuTitles: [String] = [
        "Profile",
        "Home",
        "Mentions"
    ]
    private var MenuImages: [String] = [
        "user",
        "home",
        "at"
    ]
    private var TimelineEndpoints: [TwitterClient.Timelines] = [
        TwitterClient.Timelines.Nothing,
        TwitterClient.Timelines.Home,
        TwitterClient.Timelines.Mentions
    ]
    
    var hamburgerViewController: HamburgerViewController!
    
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getMenuViewControllers()
        self.setupTable()
        self.setupProfile()
    }
    
    // --------------------------------------
    
    private func setupProfile() {
        
        if let user = State.currentUser {
            
            if let name = user.name as? String {
                self.profileName.text = name
            }
            
            if let userImage = user.profileImageURL {
                ImageLoader.loadImage(
                    userImage,
                    imageview: self.profileImage,
                    success: nil,
                    failure: nil
                )
            }
        }
    }
    
    // -------------------------------------- get vc from storyboard and instantiate
    
    private func getMenuViewControllers() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        self.ProfileNavController = storyBoard.instantiateViewControllerWithIdentifier("ProfileNavController")
//        self.MentionsNavController = storyBoard.instantiateViewControllerWithIdentifier("MentionsNavController")
        self.TweetsNavController = storyBoard.instantiateViewControllerWithIdentifier("TweetsNavController")
        
        MenuViewControllers.append(self.ProfileNavController)
        MenuViewControllers.append(self.TweetsNavController)
        MenuViewControllers.append(self.TweetsNavController)
        
        hamburgerViewController.contentViewController = MenuViewControllers[0]
    }
}

extension MenuViewController: UITableViewDelegate {
    
    private func setupTable() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = ESTIMATE_ROW_HEIGHT
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    // --------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuViewControllers.count
    }
    
    // --------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell
        
        cell.menuLabel.text = self.MenuTitles[indexPath.row]
        cell.menuIcon.image = UIImage(named: self.MenuImages[indexPath.row])

        return cell
    }
    
    // --------------------------------------
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let selectedController = self.MenuViewControllers[indexPath.row]

        if let nav = selectedController as? UINavigationController {
            let firstChildController = nav.viewControllers[0]
            self.hamburgerViewController.delegate = firstChildController as? HamburgerViewControllerDelegate
        }

        self.hamburgerViewController.endpoint = self.TimelineEndpoints[indexPath.row]
        self.hamburgerViewController.contentViewController = selectedController
    }
    
}
