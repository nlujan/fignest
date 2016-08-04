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
    @IBOutlet var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let height = self.bounds.height
        let barHeight = playerProgress.bounds.height
        let scale = (barHeight / 2.0) * (height * (1.0 / 5.0))
        
        playerProgress.transform = CGAffineTransformScale(playerProgress.transform, 1, scale)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
