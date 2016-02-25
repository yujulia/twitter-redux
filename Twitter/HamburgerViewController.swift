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
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    @IBAction func onContentPan(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(self.view)
        let velocity = sender.velocityInView(self.view)
        
        if sender.state == UIGestureRecognizerState.Began {
            self.originalLead = self.contentLead.constant
        } else if sender.state == UIGestureRecognizerState.Changed {
            self.contentLead.constant = self.originalLead + translation.x
        } else if sender.state == UIGestureRecognizerState.Ended {
            
        }
        
    }
    
}
