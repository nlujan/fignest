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
    
    
    var imageIndex = 0
    var selections: [Int] = []
    
    //var tableImages: [String] = ["pic1.jpg", "pic2.jpg", "pic3.jpg", "pic4.jpg", "pic5.jpg", "pic6.jpg"]
    var tableImages: [UIImage] = []
    
    var progressVals: [Float] = [0.2, 0.4]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerProgressTable.backgroundColor = UIColor.clearColor()
        
        tableImages = APIRequestHandler.sharedInstance.getImages()
        
        APIRequestHandler.sharedInstance.testPost();

        // Do any additional setup after loading the view.
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: foodCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("foodCell", forIndexPath: indexPath) as! foodCollectionViewCell
        
        
        //cell.foodImageView.image = UIImage(named: tableImages[indexPath.row])
        
        cell.foodImageView.image = tableImages[(imageIndex * 6) + indexPath.row]
        
        cell.layer.borderWidth = 0
        cell.layer.borderColor = UIColor.clearColor().CGColor
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("cell \(indexPath.row) selected")
        animateCellAtIndexPath(collectionView, indexPath: indexPath)
        
        selections.append( (6 * imageIndex) + indexPath.row)
        
        if (imageIndex < 4) {
            imageIndex += 1;
            //collectionView.reloadData()
            
            collectionView.performBatchUpdates(
                {
                    collectionView.reloadSections(NSIndexSet(index: 0))
                }, completion: { (finished:Bool) -> Void in
            })
            
        } else {
            print(selections)
            takeUserToPostWaitingPage();
        }
        
    }
    ///TESTTTTT
    
//    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        animateCell(cell)
//    }
    
    func animateCell(cell: UICollectionViewCell) {
//        let animation = CABasicAnimation(keyPath: "cornerRadius")
//        animation.fromValue = 200
//        cell.layer.cornerRadius = 0
//        animation.toValue = 0
//        animation.duration = 1
//        cell.layer.addAnimation(animation, forKey: animation.keyPath)
        cell.layer.borderWidth = 10.0
        cell.layer.borderColor = UIColor.greenColor().CGColor
    }
    
    func animateCellAtIndexPath(collectionView: UICollectionView, indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else { return }
        animateCell(cell)
    }
    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        animateCellAtIndexPath(indexPath)
//    }
    
    
    ///END OF TESTTTT
    
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
        
        //cell.playerImage.image = UIImage(named: tableImages[indexPath.row])
        cell.playerImage.image = tableImages[indexPath.row]
        
        cell.playerProgressBar.progress = progressVals[indexPath.row]
        
//        cell.backgroundColor = UIColor.clearColor()
        //cell.backgroundView!.backgroundColor = UIColor.clearColor()
        
        return cell
    }

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func takeUserToPostWaitingPage() {
        let postWaitingPage = self.storyboard?.instantiateViewControllerWithIdentifier("PostWaitingViewController") as! PostWaitingViewController
        
        let postWaitingPageNav = UINavigationController(rootViewController: postWaitingPage)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window!.rootViewController = postWaitingPageNav
        
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
