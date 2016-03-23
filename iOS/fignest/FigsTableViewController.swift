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
    
    var figEvents: [FigEvent] = []
    @IBOutlet var figTableView: UITableView!
    
    var figNames = ["Last Friday Night", "Recovery Brunch", "Birthday"]
    
    var numPics = [18, 4, 8]
    
    var fbUserID =  NSUserDefaults.standardUserDefaults().stringForKey("userFBID")!
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    func takeUserToLoginPage() {
        let loginPageController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window!.rootViewController = loginPageController
    }
    
    
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
        
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.barTintColor = UIColor(red: 0.549, green:0.133, blue:0.165, alpha: 1.0)
        
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        navigationController!.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        

        let userID: String = prefs.stringForKey("ID")!
        
        APIRequestHandler.sharedInstance.getUserInvitations(userID, callback: {
           
            dispatch_async(dispatch_get_main_queue(), {
                var dataArray = self.prefs.objectForKey("figInvitations") as! NSArray
                
                var eventList: [FigEvent] = []
                for event in dataArray {
                    eventList.append(FigEvent(data: event as! NSDictionary))
                }
                
                self.figEvents = eventList
                
                self.figTableView.reloadData()
                
            })
            
            
            //print("this is the real count!: \(self.figEvents.count)")
            
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        print("count: \(figEvents.count)")
        return figEvents.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FigsTableViewCell

        // Configure the cell...
        
        cell.figLabel.text = figEvents[indexPath.row].name
        cell.contentView.tag = indexPath.row

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        print("\(figNames[indexPath.row]) Selected!");
        
        let preWaitingPage = self.storyboard?.instantiateViewControllerWithIdentifier("PreWaitingViewController") as! PreWaitingViewController
        
        let preWaitingPageNav = UINavigationController(rootViewController: preWaitingPage)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window!.rootViewController = preWaitingPageNav
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
//            var svc = segue!.destinationViewController as PreWaitingNavController;
//            svc.title = "naim is bets!"
//            
//        }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(figEvents[collectionView.superview!.tag].users.count, 4)
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var numUsers = numPics[collectionView.superview!.tag]
        
        
        let cell: UserImageCell = collectionView.dequeueReusableCellWithReuseIdentifier("UserImageCell", forIndexPath: indexPath) as! UserImageCell
        
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
    
    
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
