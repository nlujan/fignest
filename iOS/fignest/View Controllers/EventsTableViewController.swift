//
//  EventsTableViewController.swift
//  fignest
//
//  Created by Naim on 3/5/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftyJSON
import Kingfisher
import DZNEmptyDataSet

class EventsTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    
    //MARK: Properties
    
    var events: [Event] = []
    var selectedEventData: Event!
    var userIDMapping: JSON = []
    let userID = NSUserDefaults.standardUserDefaults().stringForKey("ID")!
    
    var userHasNoEvents = false
    
    @IBOutlet var eventsTableView: UITableView!
    @IBOutlet var activityView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Actions
    
    @IBAction func showHomeOptions(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("User Logged Out")
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            NavigationUtil().takeUserToLoginPage(self.storyboard)
        })
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        optionMenu.view.tintColor = StyleManager().primaryColor
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){
        
    }
    
    //MARK: Functions
    
    func initTable(userID: String, completionHandler: () -> Void) {
        
        let group = dispatch_group_create()
        
        dispatch_group_enter(group)
        APIRequestHandler().getUserInvitations(userID) { eventArray in
            self.events = eventArray.map({key,subJson in Event(data: subJson)})
            dispatch_group_leave(group)
        }
        
        dispatch_group_enter(group)
        APIRequestHandler().getUsersMapById() { userIDMappingDict in
            self.userIDMapping = userIDMappingDict
            dispatch_group_leave(group)
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            self.activityView.hidden = true
            
            if self.events.count == 0 {
                self.userHasNoEvents = true
            } else {
                self.userHasNoEvents = false
            }
            
            self.eventsTableView.reloadData()
            completionHandler()
        }
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        
        print("refreshing happened!")
        
        initTable(userID) {
            refreshControl.endRefreshing()
        }
    }

    // MARK: - eventsTable DataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.events.count == 0 || self.userIDMapping.count == 0 {
            return 0
        } else {
            return events.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventsTableViewCell
        
        cell.figLabel.text = events[indexPath.row].name
        cell.searchLabel.text = events[indexPath.row].searchText
        cell.userCountLabel.text = "\(events[indexPath.row].users.count)"
        
        cell.contentView.tag = indexPath.row
        
        return cell
    }
    
    // MARK: - eventsTable Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        self.selectedEventData = events[indexPath.row]
        self.performSegueWithIdentifier("showPreWaiting", sender: nil)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor(red:0.784, green:0.78, blue:0.8, alpha:1).CGColor
        border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width:  cell.frame.size.width, height: cell.frame.size.height)
        
        border.borderWidth = width
        cell.layer.addSublayer(border)
        cell.layer.masksToBounds = true
        
//        cell.contentView.layer.borderWidth = 0.5
//        cell.contentView.layer.borderColor = UIColor.grayColor().CGColor
        
        
//        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
//        cell.layer.transform = rotationTransform
//        
//        let animationInterval = 0.3 + (0.3 * Double(indexPath.row))
//        
//        UIView.animateWithDuration(animationInterval, animations: { () -> Void in
//            cell.layer.transform = CATransform3DIdentity
//            
//        })
    }
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let height = tableView.bounds.size.height * 0.2
//        return height
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let cellWidth = collectionView.bounds.size.width * 0.22
//        return CGSizeMake(cellWidth, cellWidth)
//    }
    
    
    
//        override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//            return UITableViewAutomaticDimension
//        }
//    
//        override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//            return 100.0
//        }
    
    //MARK: picCollectionView DataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.userIDMapping.count > 0 {
            return min(events[collectionView.superview!.tag].users.count, 4)
        } else {
            return 0
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let collectionIndex = collectionView.superview!.tag
        let numUsers = events[collectionIndex].users.count
        
        let cell: UserImageCell = collectionView.dequeueReusableCellWithReuseIdentifier("UserImageCell", forIndexPath: indexPath) as! UserImageCell
        let userId = events[collectionIndex].users[indexPath.row].stringValue
        
        let fBId = userIDMapping[userId]["facebook"]["id"].stringValue
        
        cell.userImage.kf_setImageWithURL(NSURL(string: "http://graph.facebook.com/\(fBId)/picture?width=1000&height=1000")!, placeholderImage: nil)
        
        if (indexPath.row == 3 && numUsers > 4){
            cell.imageLabel.text = "+\(numUsers - 3)"
            cell.imageOverlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
        
        return cell
    }
    
     //MARK: picCollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("cell \(indexPath.row) selected")
    }
    
    
    // MARK: DZNEmptyDataSetSource
    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
        print(userHasNoEvents)
        
        if userHasNoEvents == true {
            if let view = UINib(nibName: "EmptyEvents", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? UIView {
                view.frame = scrollView.bounds
                view.translatesAutoresizingMaskIntoConstraints = false
                view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
                return view
            }
        }
        return nil
    }
    
    
    //MARK: Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        
        initTable(userID) {}
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
