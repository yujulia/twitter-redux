//
//  AccountsViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/26/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

private let ESTIMATE_ROW_HEIGHT: CGFloat = 60

class AccountsViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTable()
    }
    
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
        State.currentUser = State.users[indexPath.row]
        let hamburgerViewController = State.storyBoard.instantiateViewControllerWithIdentifier("HamburgerView")
        State.window?.rootViewController = hamburgerViewController
    }
}