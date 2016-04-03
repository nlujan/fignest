//
//  GameViewController.swift
//  fignest
//
//  Created by Naim on 3/8/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    
    var imageIndex: Int = 0
    var selections: [Int] = []
    var placesArray: NSArray = []
    var eventData: FigEvent!
    var foodImages: [UIImage] = []
    var userImages: [UIImage] = []
    var progressVals: [Float] = [0, 0]
    
    @IBOutlet var picCollectionView: UICollectionView!
    @IBOutlet var playerProgressTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerProgressTable.backgroundColor = UIColor.clearColor()
        
        //foodImages = APIRequestHandler.sharedInstance.getImages()
        
        
        var userImg: UIImage!
        let userID =  NSUserDefaults.standardUserDefaults().stringForKey("userFBID")!
        let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(userID)/picture?type=square&height=60&width=60")
        if let data = NSData(contentsOfURL: facebookProfileUrl!) {
            userImg = UIImage(data: data)!
        }
        
        userImages.append(userImg)
        userImages.append(userImg)
        
        print(eventData)
        
        APIRequestHandler.sharedInstance.getFigEventPlaces(eventData.id, callback: { ( dataArray: NSArray) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.placesArray = dataArray
                
                var images: [String] = []
                for place in dataArray {
                    images.appendContentsOf(place["images"] as! [String])
                }
                
                print(dataArray)
                print(images)
                
                self.foodImages = APIRequestHandler.sharedInstance.getImagesFromUrlStringArray(images)
                
                
                self.picCollectionView.reloadData()
                
                
            })
            
        })

        // Do any additional setup after loading the view.
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placesArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: FoodCell = collectionView.dequeueReusableCellWithReuseIdentifier("FoodCell", forIndexPath: indexPath) as! FoodCell
        
        
        //cell.foodImageView.image = UIImage(named: foodImages[indexPath.row])
        
        cell.foodImageView.image = foodImages[(imageIndex * (placesArray.count - 1)) + indexPath.row]
        
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
            
            for var i = 0; i < placesArray.count; i += 1 {
                print(i)
                
                print("place: \(placesArray[i])")
                let imageCount = placesArray[i]["images"]!!.count
                
                 for var j = 0; j < imageCount; j += 1 {
                    

                    var actionDict: [String:AnyObject] = [:]
                    let imageUrl = (placesArray[i]["images"] as! NSArray)[j] as! String
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
        
        //cell.playerImage.image = UIImage(named: foodImages[indexPath.row])
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
        
        postWaitingPage.eventData = eventData
        
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
