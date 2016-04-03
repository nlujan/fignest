//
//  FigsTableViewController.swift
//  fignest
//
//  Created by Naim on 3/5/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class FigsTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    //MARK: Properties
    
    var figEvents: [FigEvent] = []
    var selectedEventData: FigEvent!
    var userIDMapping: NSDictionary = [:]
    
    @IBOutlet var figTableView: UITableView!
    @IBOutlet var activityView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    
    
    func takeUserToLoginPage() {
        let loginPageController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window!.rootViewController = loginPageController
    }
    
    
    //MARK: Actions
    
    @IBAction func showHomeOptions(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("User Logged Out")
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            self.takeUserToLoginPage();
        })
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        let subview = optionMenu.view.subviews.first! as UIView
        let alertContentView = subview.subviews.first! as UIView
        subview.layer.cornerRadius = 2;
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        optionMenu.view.tintColor = StyleManager.sharedInstance.primaryColor
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){
        
    }
    
    private func getUserPics() {
        
        APIRequestHandler.sharedInstance.getUsersMapById({ ( dataDict: NSDictionary) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.userIDMapping = dataDict
                
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.activityView.hidden = true
                
                self.figTableView.reloadData()
            })
        })
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        activityIndicator.startAnimating()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let userID = userDefaults.stringForKey("ID")!

        //let userID: String = userDefaults.stringForKey("ID")!
        
        print("userID: \(userID)")
        
        
        APIRequestHandler.sharedInstance.getUserInvitations(userID, callback: { ( dataArray: NSArray) -> Void in
           
            dispatch_async(dispatch_get_main_queue(), {
                //var dataArray = self.userDefaults.objectForKey("figInvitations") as! NSArray
                
                var eventList: [FigEvent] = []
                for event in dataArray {
                    eventList.append(FigEvent(data: event as! NSDictionary))
                }
                
                self.figEvents = eventList
                self.getUserPics()
                
            })
        })
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        print("count: \(figEvents.count)")
        if self.userIDMapping.count == 0 {
            return 0
        } else {
            return figEvents.count
        }
        
    }

    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FigsTableViewCell

        // Configure the cell...
        
        cell.figLabel.text = figEvents[indexPath.row].name
        cell.searchLabel.text = figEvents[indexPath.row].searchText
        cell.userCountLabel.text = "\(figEvents[indexPath.row].users.count)"

        //cell.userCountLabel.text = figEvents[indexPath.row].users.count
        
        cell.contentView.tag = indexPath.row
        
        
        
        //cell.userImageCollectionView.reloadData()

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        print("\(figEvents[indexPath.row].name) Selected!");
        
        self.selectedEventData = figEvents[indexPath.row]
        
        self.performSegueWithIdentifier("showPreWaiting", sender: nil)
        
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.userIDMapping.count > 0 {
            return min(figEvents[collectionView.superview!.tag].users.count, 4)
        }
        else {
            return 0
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var collectionIndex = collectionView.superview!.tag
        
        var numUsers = figEvents[collectionIndex].users.count
        
        print(figEvents[collectionIndex].users);
        
        
        let cell: UserImageCell = collectionView.dequeueReusableCellWithReuseIdentifier("UserImageCell", forIndexPath: indexPath) as! UserImageCell
        
        let id = figEvents[collectionIndex].users[indexPath.row] as! String
        
        print("hellooo")

        let userDict = userIDMapping[id] as! NSDictionary
        let fbDict = userDict["facebook"] as! NSDictionary
        let fbId = fbDict["id"] as! String
        print("yeahhh")
        print("id: \(id)")
        var fbUserID = fbId


        
            

        
        let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(fbUserID)/picture?type=square&height=60&width=60")
        
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
    
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPreWaiting") {
            let navController = segue.destinationViewController as! UINavigationController
            let viewController = navController.topViewController as! PreWaitingViewController
            viewController.eventData = self.selectedEventData
        }
    }
    

}
