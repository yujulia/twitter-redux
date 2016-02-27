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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
