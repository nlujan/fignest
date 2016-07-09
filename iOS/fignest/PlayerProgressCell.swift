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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clearColor()
        
        playerProgressBar.transform = CGAffineTransformScale(playerProgressBar.transform, 1, 10)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
