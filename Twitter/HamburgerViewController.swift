//
//  HamburgerViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/25/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

//@objc protocol HamburgerViewControllerDelegate {
//    optional func hamburgerViewController(hamburgerViewController: HamburgerViewController, didSetEndpoint value: Int)
//}

class HamburgerViewController: UIViewController {
    
    @IBOutlet weak var contentLead: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    private var originalLead: CGFloat! = 0
    private var open: Bool = false
    
//    var delegate: HamburgerViewControllerDelegate?
    
    var menuViewController: UIViewController! {
        didSet(oldMenuViewController) {
            
            self.view.layoutIfNeeded()
            
            if oldMenuViewController != nil {
                oldMenuViewController.willMoveToParentViewController(nil)
                oldMenuViewController.view.removeFromSuperview()
                oldMenuViewController.didMoveToParentViewController(nil)
            }
            
            self.menuViewController.willMoveToParentViewController(self)
            self.menuView.addSubview(menuViewController.view)
            self.menuViewController.didMoveToParentViewController(self)
            self.view.layoutIfNeeded()
        }
    }
    
    var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            
            self.view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                oldContentViewController.willMoveToParentViewController(nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMoveToParentViewController(nil)
            }
            
            self.contentViewController.willMoveToParentViewController(self)
            self.contentView.addSubview(self.contentViewController.view)
            self.contentViewController.didMoveToParentViewController(self)
            
            self.closeMenu()
            self.view.layoutIfNeeded()
        }
    }
    
//    var endpoint: TwitterClient.Timelines? {
//        didSet {
//            if let endpointIntValue = self.endpoint?.rawValue {
//                self.delegate?.hamburgerViewController?(self, didSetEndpoint: endpointIntValue)
//            }
//        }
//    }
    
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMenu()
    }
    
    // -------------------------------------- attach menu view controller to hamburger
    
    private func setupMenu() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let menuViewController = storyBoard.instantiateViewControllerWithIdentifier("MenuView") as! MenuViewController
        menuViewController.hamburgerViewController = self
        self.menuViewController = menuViewController
    }
    
    // --------------------------------------
    
    private func closeMenu() {
        UIView.animateWithDuration(
            0.1,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.contentLead.constant = 0
                self.open = false
                self.view.layoutIfNeeded()
            },
            completion: { (done: Bool) -> Void in
                // animation done
        })
    }
    
    private func openMenu() {
        UIView.animateWithDuration(
            0.1,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.contentLead.constant = self.view.frame.size.width - 150
                self.open = true
                self.view.layoutIfNeeded()
            },
            completion: { (done: Bool) -> Void in
                // animation done
        })

    }
    
    // --------------------------------------

    @IBAction func onContentPan(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(self.view)
        let velocity = sender.velocityInView(self.view)
        
        if sender.state == UIGestureRecognizerState.Began {
            self.originalLead = self.contentLead.constant
        } else if sender.state == UIGestureRecognizerState.Changed {
            let offset = self.originalLead + translation.x
            if offset < 0 {
                return
            }
            self.contentLead.constant = offset
        } else if sender.state == UIGestureRecognizerState.Ended {
            if velocity.x > 0 {
                self.openMenu()
            } else {
                self.closeMenu()
            }
        }
    }
}
