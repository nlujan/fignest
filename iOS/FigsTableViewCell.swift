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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
