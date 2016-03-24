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
    
    var eventData: FigEvent!
    
    //var tableImages: [String] = ["pic1.jpg", "pic2.jpg", "pic3.jpg", "pic4.jpg", "pic5.jpg", "pic6.jpg"]
    var tableImages: [UIImage] = []
    
    var userImages: [UIImage] = []
    
    var progressVals: [Float] = [0, 0]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerProgressTable.backgroundColor = UIColor.clearColor()
        
        tableImages = APIRequestHandler.sharedInstance.getImages()
        
        
        var userImg: UIImage!
        var userID =  NSUserDefaults.standardUserDefaults().stringForKey("userFBID")!
        let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(userID)/picture?type=square&height=60&width=60")
        if let data = NSData(contentsOfURL: facebookProfileUrl!) {
            userImg = UIImage(data: data)!
        }
        
        userImages.append(userImg)
        userImages.append(userImg)
        
        print(eventData)
        
        APIRequestHandler.sharedInstance.getFigEventPlaces(eventData.id, callback: { ( dataArray: NSArray) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                //var dataArray = self.prefs.objectForKey("figInvitations") as! NSArray
                
//                var eventList: [FigEvent] = []
//                for event in dataArray {
//                    eventList.append(FigEvent(data: event as! NSDictionary))
//                }
//                
//                self.figEvents = eventList
                
//                self.activityIndicator.stopAnimating()
//                self.activityIndicator.hidden = true
//                self.activityView.hidden = true
//                
//                self.figTableView.reloadData()
                
                
                
                
                for place in dataArray {
                    
                }
                
                print(dataArray)
                
                
                
            })
            
        })

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
        
        imageIndex += 1;
        
        selections.append( (6 * imageIndex) + indexPath.row)
        
        SocketIOManager.sharedInstance.sendProgressUpdate(Float(imageIndex), completionHandler: { (progress) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.progressVals[1] = progress/5.0
                self.playerProgressTable.reloadData()
                
            })
        })
        
        if (imageIndex < 5) {
            //collectionView.reloadData()
            
            collectionView.performBatchUpdates(
                {
                    collectionView.reloadSections(NSIndexSet(index: 0))
                }, completion: { (finished:Bool) -> Void in
            })
            
            
            progressVals[0] = Float(imageIndex)/5.0
            playerProgressTable.reloadData()
            
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
        cell.playerImage.image = userImages[indexPath.row]
        
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
