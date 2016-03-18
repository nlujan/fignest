//
//  FigsTableViewCell.swift
//  fignest
//
//  Created by Naim on 3/5/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

class FigsTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    @IBOutlet var figLabel: UILabel!
    @IBOutlet var userImageCollectionView: UICollectionView!
    
    var numPics = [2, 4, 8]
    
    var userID =  NSUserDefaults.standardUserDefaults().stringForKey("userFBID")!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(numPics[collectionView.superview!.tag], 4)
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var numUsers = numPics[collectionView.superview!.tag]
        
        
        let cell: UserImageCell = collectionView.dequeueReusableCellWithReuseIdentifier("UserImageCell", forIndexPath: indexPath) as! UserImageCell
        
        let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(userID)/picture?type=square&height=60&width=60")
        
        if let data = NSData(contentsOfURL: facebookProfileUrl!) {
            cell.userImage.image = UIImage(data: data)
        }
        
        
        if (indexPath.row == 3 && numUsers > 4){
            cell.imageLabel.text = "+\(numUsers - 3)"
            cell.imageOverlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
           
        }
        
         return cell
        
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("cell \(indexPath.row) selected")
    }
    
    

}
