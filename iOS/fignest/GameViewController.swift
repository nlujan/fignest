//
//  GameViewController.swift
//  fignest
//
//  Created by Naim on 3/8/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var picCollectionView: UICollectionView!
    @IBOutlet var playerProgressTable: UITableView!
    
    var tableImages: [String] = ["pic1.jpg", "pic2.jpg", "pic3.jpg", "pic4.jpg", "pic5.jpg", "pic6.jpg"]
    
    var progressVals: [Float] = [0.2, 0.4]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerProgressTable.backgroundColor = UIColor.clearColor()

        // Do any additional setup after loading the view.
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: foodCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("foodCell", forIndexPath: indexPath) as! foodCollectionViewCell
        
        
        cell.foodImageView.image = UIImage(named: tableImages[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("cell \(indexPath.row) selected")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("progressCell", forIndexPath: indexPath) as! PlayerProgressCell
        
        // Configure the cell...
        
        cell.playerImage.image = UIImage(named: tableImages[indexPath.row])
        
        cell.playerProgressBar.progress = progressVals[indexPath.row]
        
//        cell.backgroundColor = UIColor.clearColor()
        //cell.backgroundView!.backgroundColor = UIColor.clearColor()
        
        return cell
    }

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
