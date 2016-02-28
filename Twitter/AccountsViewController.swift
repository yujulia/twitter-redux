//
//  AccountsViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/26/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

private let ESTIMATE_ROW_HEIGHT: CGFloat = 60

@objc protocol AccountsViewControllerDelegate {
    optional func accountsViewController(accountsViewController: AccountsViewController, didChangeUser value: User)
}

class AccountsViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    weak var hamburgerViewController: HamburgerViewController?
    weak var delegate: AccountsViewControllerDelegate?
    
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTable()
    }
    
    // --------------------------------------
    
    @IBAction func onAddAccount(sender: UIButton) {
        TwitterClient.sharedInstance.logout()
    }
}

extension AccountsViewController: UITableViewDelegate {
    
    // --------------------------------------
    
    private func setupTable() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = ESTIMATE_ROW_HEIGHT
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.tableView.backgroundColor = UIColor.clearColor()
        
    }
    
    // --------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return State.users.count
    }
    
    // --------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell", forIndexPath: indexPath) as! AccountCell
        cell.user = State.users[indexPath.row]
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    // --------------------------------------
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let newUser = State.users[indexPath.row]
        print("new user is ", newUser.screenName)
        State.currentUser = newUser
        print("current user is", State.currentUser?.screenName, indexPath.row)
        self.hamburgerViewController?.dismissAccounts()
//        self.hamburgerViewController?.dismissViewControllerAnimated(true, completion: nil)
//        self.dismissViewControllerAnimated(true, completion: nil)
   

    }
}