//
//  PlayerProgressCell.swift
//  fignest
//
//  Created by Naim on 3/10/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

class PlayerProgressCell: UITableViewCell {

 
    @IBOutlet var playerProgressBar: UIProgressView!
    @IBOutlet var playerImage: UIImageView!
    
    @IBOutlet var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clearColor()
        
        let height = self.bounds.height
        let barHeight = playerProgressBar.bounds.height
        let scale = (barHeight / 2.0) * (height * (1.0 / 5.0))
        
        playerProgressBar.transform = CGAffineTransformScale(playerProgressBar.transform, 1, scale)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
