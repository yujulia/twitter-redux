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
    
    var menuViewController: UIViewController! {
        didSet {
            self.view.layoutIfNeeded()
            self.menuView.addSubview(menuViewController.view)
        }
    }
    
    var contentViewController: UIViewController! {
        didSet {
            self.view.layoutIfNeeded()
            self.contentView.addSubview(contentViewController.view)
        }
    }
    
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // --------------------------------------

    @IBAction func onContentPan(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(self.view)
        let velocity = sender.velocityInView(self.view)
        
        if sender.state == UIGestureRecognizerState.Began {
            self.originalLead = self.contentLead.constant
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            if self.open {
                if (velocity.x <= 0) {
                    self.contentLead.constant = self.originalLead + translation.x
                }
            } else {
                if (velocity.x > 0) {
                    self.contentLead.constant = self.originalLead + translation.x
                }
            }
        
        } else if sender.state == UIGestureRecognizerState.Ended {
            
            UIView.animateWithDuration(
                0.1,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    // open
                    if velocity.x > 0 {
                        self.contentLead.constant = self.view.frame.size.width - 50
                        self.open = true
                        
                        // close
                    } else {
                        self.contentLead.constant = 0
                        self.open = false
                    }
                    self.view.layoutIfNeeded()
                },
                completion: { (done: Bool) -> Void in
                    // animation done
            })
        }
        
    }
    
}
