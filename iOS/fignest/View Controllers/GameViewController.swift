//
//  GameViewController.swift
//  fignest
//
//  Created by Naim on 3/8/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class GameViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    
    var colors: [UIColor] = StyleManager().progressViewColors
    
    let userId = NSUserDefaults.standardUserDefaults().stringForKey("ID")!
    let userFBID =  NSUserDefaults.standardUserDefaults().stringForKey("userFBID")!
    
    var picPageIndex: Int = 0
    var selections: [Int:Bool] = [:]
    var numPlaces = 0
    var eventData: Event!
    
    var foodImageStrings = []
    
    var userTableData = [["id": NSUserDefaults.standardUserDefaults().stringForKey("userFBID")!, "progress": 0]]
    
    var imagePlaceArray: [[String]] = []
    var foodImages: [UIImage] = []
    
    
    @IBOutlet var picCollectionView: UICollectionView!
    @IBOutlet var playerProgressTable: UITableView!
    
    //MARK: Functions
    
    func getPlacesImages(eventID: String) {
        APIRequestHandler().getEventPlaces(eventID, callback: { ( jsonArray: JSON) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                
                self.numPlaces = jsonArray.count

                do {
                    let foodImageStrings = self.getFoodImages(jsonArray)
                    self.foodImageStrings = foodImageStrings
                    //self.foodImages = try ImageUtil().getImagesFromUrlStringArray(foodImageStrings)
                } catch let error {
                    print(error)
                }
                
                //reload collection view
                self.picCollectionView.reloadData()
            })
        })
    }
    
    func getFoodImages(places: JSON) -> [String] {
        
        var tempPlaceArray: [[String]] = []
 
        for (_,place):(String, JSON) in places {
            for i in 0 ..< 6 {
                tempPlaceArray.append([place["images"].arrayValue[i].stringValue, place["_id"].stringValue])
            }
        }
        
        imagePlaceArray = tempPlaceArray.shuffle()
        
        return imagePlaceArray.map({imagePlace in imagePlace[0]})
    }
    
    func getActionObject(selections: [Int:Bool]) -> [NSDictionary]{
        
        var actionData = [[:]]
        
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
    
    func postAction(userID: String, eventID: String, selections: [NSDictionary]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            APIRequestHandler().postEventAction(userID, eventID: eventID, selections: selections, callback: { ( dataDict: NSDictionary) -> Void in
            })
        })
    }
    
    func setupProgressListener() {
        SocketIOManager.sharedInstance.setupProgressListener({ (progressData: JSON) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                
                let fbID = progressData[0]["user"]["facebook"]["id"].stringValue
                let progress = progressData[0]["level"].floatValue 
                
                print("level: \(progress)")
                print("fbID: \(fbID)")
                
                if self.userTableData.count == 1 {
                    self.userTableData.append(["id":fbID, "progress": progress])
                } else {
                    self.userTableData[1] = ["id":fbID, "progress": progress]
                }
                
                self.playerProgressTable.reloadData()
            })
        })
    }
    
    func sendProgress(userId: String, eventId: String, level: Float) {
        SocketIOManager.sharedInstance.sendProgress(userId, eventId: eventId, level: level)
    }
    
    func takeUserToPostWaitingPage() {
        let postWaitingPage = self.storyboard?.instantiateViewControllerWithIdentifier("PostWaitingViewController") as! PostWaitingViewController
        let postWaitingPageNav = UINavigationController(rootViewController: postWaitingPage)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // pass event data to postWaiting screen
        postWaitingPage.eventData = eventData
        
        appDelegate.window!.rootViewController = postWaitingPageNav
    }
    
    //MARK: picCollectionView DataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if foodImageStrings.count == 0 {
            return 0
        } else {
            return 6
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: FoodCell = collectionView.dequeueReusableCellWithReuseIdentifier("FoodCell", forIndexPath: indexPath) as! FoodCell
        let picIndex = (picPageIndex * 6) + indexPath.row
        
        //cell.foodImageView.image = foodImages[picIndex]
        //cell.foodImageView.kf_setImageWithURL(NSURL(string: foodImageStrings[picIndex] as! String)!, placeholderImage: nil)
        
        cell.foodImageView.kf_setImageWithURL(NSURL(string: foodImageStrings[picIndex] as! String)!,
                                     placeholderImage: nil,
                                     optionsInfo: [.Transition(ImageTransition.Fade(1))])

        
        return cell
    }
    
    //MARK: picCollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        cell.layer.borderWidth = 0.0
        
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
        
        let val = Float(picPageIndex)/Float(numPlaces)
        let cell = playerProgressTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! PlayerProgressCell
        cell.playerProgressBar.setProgress(val, animated: true)
        
        userTableData[0] = ["id": NSUserDefaults.standardUserDefaults().stringForKey("userFBID")!, "progress": val]
        
        sendProgress(userId, eventId: eventData.id, level: val)
        
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

        if (picPageIndex < numPlaces) {
            collectionView.reloadData()
        } else {
            let actionData = getActionObject(selections)
            postAction(userId, eventID: eventData.id, selections: actionData)
            
            takeUserToPostWaitingPage()
        }
        
    }
    
    ///TESTTTTT
    
//    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        animateCell(cell)
//    }
    
    func animateCell(cell: UICollectionViewCell) {
    }
    
    func animateCellAtIndexPath(collectionView: UICollectionView, indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else { return }
        animateCell(cell)
    }
    
    
    ///END OF TESTTTT
    
    //MARK: playerProgressTable DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userTableData.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("progressCell", forIndexPath: indexPath) as! PlayerProgressCell
        
        let user = userTableData[indexPath.row]
        
        cell.playerImage.image = ImageUtil().getFBImageFromID(user["id"] as! String)

        
        cell.playerProgressBar.progress = user["progress"] as! Float
        cell.playerProgressBar.tintColor = colors[indexPath.row]
        cell.playerProgressBar.trackTintColor = colors[indexPath.row].colorWithAlphaComponent(0.2)
        
        return cell
    }
    
    //MARK: Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPlacesImages(eventData.id)
        
        setupProgressListener()
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
