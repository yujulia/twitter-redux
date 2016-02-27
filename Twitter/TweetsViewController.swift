//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/22/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit
import MBProgressHUD

class TweetsViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let ESTIMATE_ROW_HEIGHT: CGFloat = 120.0
    let RESPONSE_LIMIT = 20
    let client = TwitterClient.sharedInstance
    let refreshControl = UIRefreshControl()
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    private var loading: Bool = false
    private var hud: MBProgressHUD?
    
    var endpoint = TwitterClient.Timelines.Mentions
    var profileViewController: ProfileViewController?
    
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTable()
        self.setupRefresh()
        
        self.profileViewController = storyBoard.instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController
    }

    // -------------------------------------- load the timeline
    
    private func loadTimeline(last_id: String?) {

        self.isLoading()
        
        client.loadTimelineOfType(
            self.endpoint,
            last_id: last_id,
            success: { () -> () in
                
                print("timeline got success")
                if last_id != nil {

                    self.loadMoreDone()
                } else {
                    self.loadDone()
                }
            },
            failure: { (error: NSError) -> () in
                self.loadError(error)
            }
        )
    }
    
    private func loadError(error: NSError) {
        self.notLoading()
        print("tweets vc couldnt get tweets", error.localizedDescription)
    }
    
    private func loadDone() {
        print("this is load done")
        self.notLoading()
        self.tableView.reloadData()
    }
    
    private func loadMoreDone() {
        
        print("load more done")
        self.notLoading()
        
        if State.lastBatchCount <= 0 {
            print("Load more returned no more tweets")
            return
        }
        
        let startRow = State.currentHomeTweetCount - State.lastBatchCount
        var addPaths = [NSIndexPath]()
        
        for index in startRow...startRow + State.lastBatchCount - 1 {
            addPaths.append(NSIndexPath(forRow: index, inSection: 0))
        }
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(addPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView.endUpdates()
    }
    
    private func isLoading() {
        self.loading = true
        self.refreshControl.endRefreshing()
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    private func notLoading() {
        self.loading = false
        self.refreshControl.endRefreshing()
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
    // ------------------------------------------ set up refresh control
    
    private func setupRefresh() {
        self.refreshControl.tintColor = UIColor.blackColor()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(self.refreshControl, atIndex: 0)
    }
    
    //-------------------------------------------- pull to refresh load data
    
    func refresh(refreshControl: UIRefreshControl) {
        self.loadTimeline(nil)
    }
    
    // -------------------------------------- logout
    
    @IBAction func logoutTapped(sender: UIButton) {
        self.client.logout()
    }
    
    // -------------------------------------- update the title
    
    private func setTitle() {
        if self.endpoint == TwitterClient.Timelines.Home {
            self.title = "Home"
        } else if self.endpoint == TwitterClient.Timelines.Mentions {
            self.title = "Mentions"
        } else {
            self.title = "? Timeline"
        }
    }
    
    // -------------------------------------- segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "TweetDetailSegue" {
            let detailViewController = segue.destinationViewController as! TweetDetailViewController
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            let currentCellData = State.timelineTweets?[indexPath!.row]
            
            detailViewController.delegate = self
            detailViewController.data = currentCellData
        }
        
        if segue.identifier == "ComposeSegue" {
            let composeViewController = segue.destinationViewController as! ComposeViewController
            composeViewController.delegate = self
            
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(cell)
                let currentCellData = State.timelineTweets?[indexPath!.row]
                composeViewController.replyToTweet = currentCellData
            }
        }
        
        if segue.identifier == "ProfileSegue" {
            let profileViewController = segue.destinationViewController as! ProfileViewController
            
            if let user = sender as? User {
                profileViewController.user = user
            }
        }
    }
}

// table view delegate 

extension TweetsViewController: UITableViewDelegate {
    
    // --------------------------------------
    
    private func setupTable() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = ESTIMATE_ROW_HEIGHT
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    // --------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = State.timelineTweets {
            return tweets.count
        } else {
            return 0
        }
    }
    
    // --------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        
        if let cellData = State.timelineTweets?[indexPath.row] {
            cell.data = cellData
        }

        cell.delegate = self
        
        if indexPath.row >= State.timelineTweets!.count-1 {
            if let cellData = State.timelineTweets?[indexPath.row] {
                self.loadTimeline(cellData.id!)
            }
        }
    
        return cell
    }
    
}

// tweet cell delegate

extension TweetsViewController: TweetCellDelegate {
    
    // -------------------------------------- show compose view
    
    func tweetCell(tweetCell: TweetCell, didWantToReply value: TweetCell) {
        self.performSegueWithIdentifier("ComposeSegue", sender: value)
    }
    
    // -------------------------------------- show profile view
    
    func tweetCell(tweetCell: TweetCell, didWantToShowProfile value: User) {
        
        if let profileViewController = self.profileViewController {
            profileViewController.user = value
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
        
    }
}

// tweet detail delegate

extension TweetsViewController: TweetDetailViewControllerDelegate {
    
    // -------------------------------------- do retweet stuf... not implemented
    
    func tweetDetailViewController(tweetDetailViewController: TweetDetailViewController, didRetweet value: Tweet) {
        print("retweeted got info from detail but i guess i'll do nothing...")

    }
}

// compose delegate

extension TweetsViewController: ComposeViewControllerDelegate {
    
    // -------------------------------------- compose tweeted, add the new tweet
    
    func composeViewController(composeViewController: ComposeViewController, didTweet value: Tweet) {
        
        State.timelineTweets?.insert(value, atIndex: 0)
        
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView.endUpdates()
    }
}

// menu delegate

extension TweetsViewController: MenuViewControllerDelegate {
    
    // -------------------------------------- content was set on hamburger callback
    
    func menuViewController(menuViewController: MenuViewController, didSetContentOnHamburger value: UIViewController, endpoint: Int) {
        
        if let endpointType = TwitterClient.Timelines(rawValue: endpoint) {
            self.endpoint = endpointType
            self.setTitle()
            self.loadTimeline(nil)
        }
    }
}
