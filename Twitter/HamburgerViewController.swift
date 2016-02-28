//
//  HamburgerViewController.swift
//  Twitter
//
//  Created by Julia Yu on 2/25/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {
    
    @IBOutlet weak var contentLead: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    private var originalLead: CGFloat! = 0
    private var open: Bool = false
    private var accountsViewController: AccountsViewController!
    
    var menuViewController: MenuViewController! {
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
            
            print("reloading content view")
            
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
    
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMenu()
        
        self.accountsViewController = State.storyBoard.instantiateViewControllerWithIdentifier("AccountsViewController") as! AccountsViewController
        self.accountsViewController.hamburgerViewController = self
    }
    
    // -------------------------------------- attach menu view controller to hamburger
    
    private func setupMenu() {
        let menuViewController = State.storyBoard.instantiateViewControllerWithIdentifier("MenuView") as! MenuViewController
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
    
    func presentAccounts() {
        self.presentViewController(self.accountsViewController, animated: true, completion: nil)
        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let window = appDelegate.window!
//        
//        UIView.transitionWithView(
//            window,
//            duration: 0.5,
//            options: UIViewAnimationOptions.TransitionFlipFromLeft,
//            animations: { () -> Void in
//                window.rootViewController = self.accountsViewController
//            }, completion: nil)
    }
    
    func dismissAccounts() {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.menuViewController.setupProfile()
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
