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
    var placesArray: NSArray = []
    
    var eventData: FigEvent!
    
    var tableImages: [UIImage] = []
    
    var userImages: [UIImage] = []
    
    var progressVals: [Float] = [0, 0]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerProgressTable.backgroundColor = UIColor.clearColor()
        
        //tableImages = APIRequestHandler.sharedInstance.getImages()
        
        
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
                
                self.placesArray = dataArray
                
                var images: [String] = []
                for place in dataArray {
                    images.appendContentsOf(place["images"] as! [String])
                }
                
                print(dataArray)
                print(images)
                
                self.tableImages = APIRequestHandler.sharedInstance.getImagesFromUrlStringArray(images)
                
                
                self.picCollectionView.reloadData()
                
                
            })
            
        })

        // Do any additional setup after loading the view.
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placesArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: foodCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("foodCell", forIndexPath: indexPath) as! foodCollectionViewCell
        
        
        //cell.foodImageView.image = UIImage(named: tableImages[indexPath.row])
        
        cell.foodImageView.image = tableImages[(imageIndex * (placesArray.count - 1)) + indexPath.row]
        
        cell.layer.borderWidth = 0
        cell.layer.borderColor = UIColor.clearColor().CGColor
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("cell \(indexPath.row) selected")
        animateCellAtIndexPath(collectionView, indexPath: indexPath)
        
        
        
        selections.append( (6 * imageIndex) + indexPath.row)
        
        imageIndex += 1;
        
        SocketIOManager.sharedInstance.sendProgressUpdate(Float(imageIndex), completionHandler: { (progress) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.progressVals[1] = progress/Float(self.placesArray.count)
                self.playerProgressTable.reloadData()
                
            })
        })
        
        if (imageIndex < 6) {
            //collectionView.reloadData()
            
            collectionView.performBatchUpdates(
                {
                    collectionView.reloadSections(NSIndexSet(index: 0))
                }, completion: { (finished:Bool) -> Void in
            })
            
            
            progressVals[0] = Float(imageIndex)/Float(self.placesArray.count)
            playerProgressTable.reloadData()
            
        } else {
            print(selections)
            
            var actionData: [NSDictionary] = []
            
            print("placesArray: \(placesArray)")
            
            for var i = 0; i < placesArray.count; i++ {
                print(i)
                
                print("place: \(placesArray[i])")
                var imageCount = placesArray[i]["images"]!!.count
                
                 for var j = 0; j < imageCount; j++ {
                    
                    
                    
                    var actionDict: [String:AnyObject] = [:]
                    let imageUrl = placesArray[i]["images"]!![j] as! String
                    print("what is this?:\(imageUrl)")

                    let id = placesArray[i]["_id"] as! String
                    
                    actionDict["image"] = imageUrl
                    actionDict["place"] = id
                    
                    if ((i*6) + j) == selections[i] {
                        actionDict["isSelected"] = true
                    } else {
                        actionDict["isSelected"] = false
                    }
                    
                    actionData.append(actionDict)
                }
                
                print(actionData)
                
                
            }
            
            
            APIRequestHandler.sharedInstance.postAction(NSUserDefaults.standardUserDefaults().stringForKey("ID")!, eventID: eventData.id, selections: actionData, callback: { ( dataDict: NSDictionary) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    
                    print(dataDict)
                    
                    print("everything is awesome!")
                })
                
                
                
            })
            
            func setTimeout(delay:NSTimeInterval, block:()->Void) -> NSTimer {
                return NSTimer.scheduledTimerWithTimeInterval(delay, target: NSBlockOperation(block: block), selector: "main", userInfo: nil, repeats: false)
            }
            
            func getResult()  {
                APIRequestHandler.sharedInstance.getSolution(eventData.id, callback: { ( dataDict: NSDictionary) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        print(dataDict)
                        
                        print("We did it!!")
                        
                    })
                    
                })
                
            }
            
            setTimeout(10.0, block:getResult)
            
            
            

            
            
            
    
            
            takeUserToPostWaitingPage();
        }
        
    }
    ///TESTTTTT
    
//    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        animateCell(cell)
//    }
    
    func animateCell(cell: UICollectionViewCell) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 0.5
        cell.layer.addAnimation(animation, forKey: animation.keyPath)
        
        cell.layer.borderWidth = 5.0
        cell.layer.borderColor = UIColor(red: 0.549, green:0.133, blue:0.165, alpha: 1.0).CGColor
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
