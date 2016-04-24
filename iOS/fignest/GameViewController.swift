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
    
    var testIds: [String] = ["584566895045734", "10208530090233237"]
    var colors: [UIColor] = StyleManager().progressViewColors
    
    var picPageIndex: Int = 0
    var selections: [Int:Bool] = [:]
    var placesArray: NSArray = []
    var eventData: Event!
    
    var imagePlaceArray: [[String]] = []
    var foodImages: [UIImage] = []
    
    var userImages: [UIImage] = []
    var progressVals: [Float] = [0, 0]
    
    @IBOutlet var picCollectionView: UICollectionView!
    @IBOutlet var playerProgressTable: UITableView!
    
    //MARK: API Functions
    
    func getPlacesImages(eventID: String) {
        APIRequestHandler().getFigEventPlaces(eventID, callback: { ( dataArray: NSArray) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.placesArray = dataArray
                
                //set the images to be desiplayed
                self.getFoodImages(dataArray)
                
                //reload collectin view
                self.picCollectionView.reloadData()
            })
        })
    }
    
    func postAction(userID: String, eventID: String, selections: [NSDictionary]) {
        APIRequestHandler().postAction(userID, eventID: eventID, selections: selections, callback: { ( dataDict: NSDictionary) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                
                //print(dataDict)
                //print("Action Posted!")
            })
        })
    }
    
    //MARK: Additional Functions
    
    func takeUserToPostWaitingPage() {
        let postWaitingPage = self.storyboard?.instantiateViewControllerWithIdentifier("PostWaitingViewController") as! PostWaitingViewController
        let postWaitingPageNav = UINavigationController(rootViewController: postWaitingPage)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // pass event data to postWaiting screen
        postWaitingPage.eventData = eventData
        
        appDelegate.window!.rootViewController = postWaitingPageNav
        
    }
    
    func getFoodImages(places: NSArray) {
        
        for place in places {
            for i in 0 ..< 6 {
                imagePlaceArray.append([(place["images"] as! [String])[i], place["_id"] as! String])
            }
        }
        
        let newimagePlaceArray = imagePlaceArray.shuffle()
        let images = newimagePlaceArray.map({imagePlace in imagePlace[0]})
        
        self.foodImages = ImageUtil.sharedInstance.getImagesFromUrlStringArray(images)
    }
    
    func getActionObject(selections: [Int:Bool]) -> [NSDictionary]{
        
        var actionData: [NSDictionary] = []
        
        for i in 0 ..< imagePlaceArray.count {
            var actionDict: [String:AnyObject] = [:]
            
            actionDict["image"] = imagePlaceArray[i][0]
            actionDict["place"] = imagePlaceArray[i][1]
            
            if selections[i] != nil {
                actionDict["isSelected"] = true
            } else {
                actionDict["isSelected"] = false
            }
            
            actionData.append(actionDict)
        }
        
        return actionData
    }
    
    //MARK: picCollectionView DataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if foodImages.isEmpty {
            return 0
        } else {
            return 6
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: FoodCell = collectionView.dequeueReusableCellWithReuseIdentifier("FoodCell", forIndexPath: indexPath) as! FoodCell
        let picIndex = (picPageIndex * 6) + indexPath.row
        
        cell.foodImageView.image = foodImages[picIndex]
        
        cell.layer.borderWidth = 0
        cell.layer.borderColor = UIColor.clearColor().CGColor
        
        return cell
    }
    
    //MARK: picCollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        cell.alpha = 0
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            cell.alpha = 1
        }, completion: nil)
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        picPageIndex += 1
        
        guard let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) else { return }
        selectedCell.layer.borderWidth = 5.0
        selectedCell.layer.borderColor = UIColor(red: 0.549, green:0.133, blue:0.165, alpha: 1.0).CGColor
        
        var cells: [UICollectionViewCell] = []
        for i in 0 ..< 6 {
            if i != indexPath.row {
                guard let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) else { return }
                cells.append(cell)
            }
        }
        
        //guard let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) else { return }
        
        for cell in cells {
            cell.alpha = 1
        }
        
        let val = Float(picPageIndex)/Float(self.placesArray.count)
        let cell = playerProgressTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! PlayerProgressCell
        cell.playerProgressBar.setProgress(val, animated: true)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            for cell in cells {
                cell.alpha = 0
            }
    
            }, completion: {(finished:Bool) in
                // the code you put here will be compiled once the animation finishes
                
                self.picSelectedHandler(collectionView, indexPath: indexPath)
        })
    }
    
    
    func picSelectedHandler(collectionView: UICollectionView, indexPath: NSIndexPath) {
        selections[(6 * picPageIndex) + indexPath.row] = true

        if (picPageIndex < placesArray.count) {
            
            collectionView.reloadData()

        } else {

            let actionData = getActionObject(selections)
            postAction(NSUserDefaults.standardUserDefaults().stringForKey("ID")!, eventID: eventData.id, selections: actionData)
            
            takeUserToPostWaitingPage()
        }
        
    }
    
    ///TESTTTTT
    
//    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        animateCell(cell)
//    }
    
    func animateCell(cell: UICollectionViewCell) {
//        let animation = CABasicAnimation(keyPath: "opacity")
//        animation.fromValue = 1
//        animation.toValue = 0
//        animation.duration = 0.5
//        cell.layer.addAnimation(animation, forKey: animation.keyPath)
        
//        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
//        cell.layer.transform = rotationTransform
        
        cell.alpha = 1
        
        //let animationInterval = 0.7 + (0.3 * Double(indexPath.row))
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            cell.alpha = 0
            
        })
        
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
    
    //MARK: playerProgressTable DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("progressCell", forIndexPath: indexPath) as! PlayerProgressCell

        cell.playerImage.image = ImageUtil.sharedInstance.getFBImageFromID(testIds[indexPath.row])
        
        cell.playerProgressBar.progress = progressVals[indexPath.row]
        
        
        cell.playerProgressBar.tintColor = colors[indexPath.row]
        
        cell.playerProgressBar.trackTintColor = colors[indexPath.row].colorWithAlphaComponent(0.2)
        
        
        
        
        return cell
    }
    
    //MARK: Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerProgressTable.backgroundColor = UIColor.clearColor()
        
        var userImg: UIImage!
        let userFBID =  NSUserDefaults.standardUserDefaults().stringForKey("userFBID")!
        let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(userFBID)/picture?type=square&height=60&width=60")
        if let data = NSData(contentsOfURL: facebookProfileUrl!) {
            userImg = UIImage(data: data)!
        }
        
        userImages.append(userImg)
        userImages.append(userImg)
        

        getPlacesImages(eventData.id)
            
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
