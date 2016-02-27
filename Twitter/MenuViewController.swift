//
//  MenuViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/25/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

@objc protocol MenuViewControllerDelegate {
    optional func menuViewController(menuViewController: MenuViewController, didSetContentOnHamburger value: UIViewController, endpoint: Int)
}

class MenuViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let ESTIMATE_ROW_HEIGHT: CGFloat = 120.0
    
    private var MenuViewControllers: [UIViewController] = []
    private var ProfileController: UIViewController!
    private var TweetsNavController: UIViewController!
    private var ExtraNavController: UIViewController!
    
    private var MenuTitles: [String] = [
        "Profile",
        "Home",
        "Mentions",
        "Extra"
    ]
    private var MenuImages: [String] = [
        "user",
        "home",
        "at",
        "Twitter_logo_blue_48"
    ]
    private var TimelineEndpoints: [TwitterClient.Timelines] = [
        TwitterClient.Timelines.Nothing,
        TwitterClient.Timelines.Home,
        TwitterClient.Timelines.Mentions,
        TwitterClient.Timelines.Nothing
    ]
    
    var hamburgerViewController: HamburgerViewController!
    
    weak var delegate: MenuViewControllerDelegate?
    
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
            
            if let name = user.screenName as? String {
                self.profileName.text = "@" + name
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
    
    // -------------------------------------- menu self image tap
    
    @IBAction func profileTapped(sender: AnyObject) {
        hamburgerViewController.contentViewController = MenuViewControllers[0]
    }
    
    // -------------------------------------- get vc from storyboard and instantiate
    
    private func getMenuViewControllers() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        self.ProfileController = storyBoard.instantiateViewControllerWithIdentifier("ProfileViewController")
        self.ExtraNavController = storyBoard.instantiateViewControllerWithIdentifier("ExtraNav")
        self.TweetsNavController = storyBoard.instantiateViewControllerWithIdentifier("TweetsNavController")
        
        MenuViewControllers.append(self.ProfileController)
        MenuViewControllers.append(self.TweetsNavController)
        MenuViewControllers.append(self.TweetsNavController)
        MenuViewControllers.append(self.ExtraNavController)
        
        self.setDefaultContentViewAs(1)
        
    }
    
    // -------------------------------------- set the default view
    
    private func setDefaultContentViewAs(index: Int) {
        
        hamburgerViewController.contentViewController = MenuViewControllers[index]
        
        // if this is a nav controller, set up the delegate on its view controller
        
        if let navController = hamburgerViewController.contentViewController as? UINavigationController {
            let firstChildController = navController.topViewController as? TweetsViewController
            self.delegate = firstChildController as? MenuViewControllerDelegate
            self.delegate?.menuViewController?(self, didSetContentOnHamburger: hamburgerViewController.contentViewController, endpoint: self.TimelineEndpoints[index].rawValue)
        }
        
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
            self.delegate = firstChildController as? MenuViewControllerDelegate
        }
        
        self.hamburgerViewController.contentViewController = selectedController
        self.delegate?.menuViewController?(self, didSetContentOnHamburger: selectedController, endpoint: self.TimelineEndpoints[indexPath.row].rawValue)
    }
    
}
