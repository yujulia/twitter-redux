//
//  MenuViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/25/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let ESTIMATE_ROW_HEIGHT: CGFloat = 120.0
    
    private var MenuViewControllers: [UIViewController] = []
    private var ProfileNavController: UIViewController!
    private var MentionsNavController: UIViewController!
    private var HomeNavController: UIViewController!
    
    private var MenuTitles: [String] = ["Profile", "Home", "Mentions"]
    
    
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getMenuViewControllers()
        self.setupTable()
    }
    
    // -------------------------------------- get vc from storyboard and instantiate
    
    private func getMenuViewControllers() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        self.ProfileNavController = storyBoard.instantiateViewControllerWithIdentifier("ProfileNav")
        self.MentionsNavController = storyBoard.instantiateViewControllerWithIdentifier("MentionsNav")
        self.HomeNavController = storyBoard.instantiateViewControllerWithIdentifier("HomeNavController")
        
        MenuViewControllers.append(self.ProfileNavController)
        MenuViewControllers.append(self.HomeNavController)
        MenuViewControllers.append(self.MentionsNavController)
        
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

        return cell
    }
    
}
