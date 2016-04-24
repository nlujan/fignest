//
//  EventsTableViewCell.swift
//  fignest
//
//  Created by Naim on 3/5/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell {
    
    @IBOutlet var figLabel: UILabel!
    @IBOutlet var userImageCollectionView: UICollectionView!
    @IBOutlet var personIcon: UIImageView!
    @IBOutlet var userCountLabel: UILabel!
    @IBOutlet var searchLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        personIcon.image = personIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        personIcon.tintColor = StyleManager().primaryColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
