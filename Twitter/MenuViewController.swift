//
//  MenuViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/25/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource {
    
    let ESTIMATE_ROW_HEIGHT: CGFloat = 120.0

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTable()

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
        
        if let items = State.menuItems {
            return items.count
        } else {
            return 0
        }
    }
    
    // --------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell
        
        cell.menuLabel.text = String(indexPath.row)

        return cell
    }
    
}
