//
//  FigsTableViewCell.swift
//  fignest
//
//  Created by Naim on 3/5/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

class FigsTableViewCell: UITableViewCell {
    
    @IBOutlet var figLabel: UILabel!
    @IBOutlet var userImageCollectionView: UICollectionView!
    @IBOutlet var personIcon: UIImageView!
    @IBOutlet var userCountLabel: UILabel!
    @IBOutlet var searchLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        personIcon.image = personIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        personIcon.tintColor = StyleManager.sharedInstance.primaryColor

        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
