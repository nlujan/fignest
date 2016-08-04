//
//  PostWaitingViewController.swift
//  fignest
//
//  Created by Naim on 3/19/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import SwiftyJSON

class PostWaitingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    
    var userTableData = [[String:AnyObject]]()
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var eventData: Event?
    var colors: [UIColor] = StyleUtil().progressViewColors
    let userId = NSUserDefaults.standardUserDefaults().stringForKey("ID")!
    
    @IBOutlet var postWaitingTable: UITableView!
    
    //MARK: Actions
    
    @IBAction func showOptions(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        
        //for testing
        
        let showResultsAction = UIAlertAction(title: "Show Results", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.performSegueWithIdentifier("ShowResults", sender: nil)
        })
        
        
        
        
        let logoutAction = UIAlertAction(title: "Exit Fig", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            NavigationUtil().takeUserToHomePage(self.storyboard)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            //print("Cancelled")
        })
        optionMenu.addAction(showResultsAction)
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        optionMenu.view.tintColor = StyleUtil().primaryColor
    }
    
    @IBAction func sendPostWaitingMessage(sender: UIButton) {
        sendMessage(userId, eventId: eventData!.id, message: sender.currentTitle!)
    }
    
    //MARK: Functions
    
    func emitDone(userId: String, eventId: String) {
        SocketIOManager.sharedInstance.emitDone(userId, eventId: eventId)
    }
    
    func sendMessage(userId: String, eventId: String, message: String) {
        SocketIOManager.sharedInstance.sendMessage(userId, eventId: eventId, message: message)
    }
    
    func setupProgressAllListener() {
        SocketIOManager.sharedInstance.setupProgressAllListener() { userList in
            dispatch_async(dispatch_get_main_queue(), {
                //print("User has finished game!!");
                
                var tempData = [[String:AnyObject]]()
                
                for (_,user) in userList {
                    if user["level"].float != nil {
                        if user["hasMessage"].boolValue {
                            tempData.append(["id": user["facebook"]["id"].stringValue, "message": user["message"].stringValue])
                        } else {
                            tempData.append(["id": user["facebook"]["id"].stringValue, "progress": user["level"].floatValue])
                        }
                    } else {
                        tempData.append(["id": user["facebook"]["id"].stringValue, "progress": 0.0])
                    }
                }
                self.userTableData = tempData
                self.postWaitingTable.reloadData()
            })
        }
    }
    
    func setupFinishListener() {
        SocketIOManager.sharedInstance.setupFinishListener() {
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("ShowResults", sender: nil)
            })
        }
    }
    
    //MARK: Table DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userTableData.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostWaitingCell", forIndexPath: indexPath) as! PostWaitingCell
        
        let user = userTableData[indexPath.row]
        
        let URL = NSURL(string: ImageUtil().getFBImageURL(user["id"] as! String))!
        
        cell.playerImg.af_setImageWithURL(URL)
        
        
        if let message = user["message"] {
            cell.playerProgress.hidden = true
            cell.messageLabel.hidden = false
            cell.messageLabel.text = (message as! String)
        } else {
            cell.playerProgress.hidden = false
            cell.messageLabel.hidden = true
            
            cell.playerProgress.progress = user["progress"] as! Float
            cell.playerProgress.tintColor = colors[indexPath.row]
            cell.playerProgress.trackTintColor = colors[indexPath.row].colorWithAlphaComponent(0.2)
        }
        
        return cell
        
    }
    
    //MARK: Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        
        setupProgressAllListener()
        setupFinishListener()
        emitDone(userId, eventId: eventData!.id)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "ShowResults") {
            let viewController = segue.destinationViewController as! ResultsViewController
            
            viewController.eventData = self.eventData
        }
    }
}
