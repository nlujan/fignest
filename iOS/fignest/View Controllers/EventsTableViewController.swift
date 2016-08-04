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
import DZNEmptyDataSet
import AlamofireImage

class EventsTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    //MARK: Properties
    
    var events: [Event] = []
    var selectedEventData: Event!
    var userIDMapping: JSON = []
    var userHasNoEvents = false
    
    let userID = NSUserDefaults.standardUserDefaults().stringForKey("ID")!
    
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
        optionMenu.view.tintColor = StyleUtil().primaryColor
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
    
    //MARK: Functions
    
    func initTable(userID: String, completionHandler: () -> Void) {
        
        let group = dispatch_group_create()
        
        dispatch_group_enter(group)
        APIRequestManager().getUserInvitations(userID) { eventArray in
            self.events = eventArray.map({key,subJson in Event(data: subJson)})
            dispatch_group_leave(group)
        }
        
        dispatch_group_enter(group)
        APIRequestManager().getUsersMapById() { userIDMappingDict in
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
        
        initTable(userID) {
            refreshControl.endRefreshing()
        }
    }

    // MARK: - UITableViewDataSource

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
    
    // MARK: - UITableViewDelegate
    
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
    }
    
    //MARK: UICollectionViewDataSource
    
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
        let URL = NSURL(string: "http://graph.facebook.com/\(fBId)/picture?width=1000&height=1000")!
        
        cell.userImage.af_setImageWithURL(URL)
        
        if (indexPath.row == 3 && numUsers > 4){
            cell.imageLabel.text = "+\(numUsers - 3)"
            cell.imageOverlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
        
        return cell
    }
    
     //MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("cell \(indexPath.row) selected")
    }
    
    
    // MARK: DZNEmptyDataSetSource
    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {

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
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
