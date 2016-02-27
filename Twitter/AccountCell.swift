//
//  AccountCell.swift
//  Twitter
//
//  Created by Julia Yu on 2/26/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userIcon: UIImageView!
    
    var user: User? {
        didSet {
            self.setDataAsProperty()
        }
    }
    
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // --------------------------------------
    
    private func setDataAsProperty() {
        if let user = self.user {
            self.userName.text = user.name
            
            if let userImage = user.profileImageURL {
                ImageLoader.loadImage(
                    userImage,
                    imageview: self.userIcon,
                    success: nil,
                    failure: nil
                )
            }
            
        }
    }
}
