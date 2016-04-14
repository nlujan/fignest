//
//  PostWaitingCell.swift
//  fignest
//
//  Created by Naim on 3/19/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

class PostWaitingCell: UITableViewCell {
    
    @IBOutlet var playerImg: UIImageView!
    @IBOutlet var playerProgress: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        playerProgress.transform = CGAffineTransformScale(playerProgress.transform, 1, 10)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
