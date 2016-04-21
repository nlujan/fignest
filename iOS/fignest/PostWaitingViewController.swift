//
//  PostWaitingViewController.swift
//  fignest
//
//  Created by Naim on 3/19/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

class PostWaitingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    
    var progressData: [[AnyObject]] = [["584566895045734", 1.0], ["10208530090233237", 0.5], ["584566895045734", 0.3]]
    var eventData: Event?
    var colors: [UIColor] = StyleManager().progressViewColors
    
    //MARK: Actions
    
    @IBAction func showOptions(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Exit Fig", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.takeUserToHomePage();
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
    
    @IBAction func sendPostWaitingMessage(sender: UIButton) {
        print(sender.currentTitle!)
    }
    
    //MARK: Functions
    
    func takeUserToHomePage() {
        let homePage = self.storyboard?.instantiateViewControllerWithIdentifier("EventsTableViewController") as! EventsTableViewController
        
        let homePageNav = UINavigationController(rootViewController: homePage)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window!.rootViewController = homePageNav
    }
    
    //MARK: Table DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return progressData.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostWaitingCell", forIndexPath: indexPath) as! PostWaitingCell
        
        cell.playerImg.image = ImageUtil.sharedInstance.getFBImageFromID(progressData[indexPath.row][0] as! String)
        cell.playerProgress.progress = progressData[indexPath.row][1] as! Float
        cell.playerProgress.tintColor = colors[indexPath.row]
        
        cell.playerProgress.trackTintColor = colors[indexPath.row].colorWithAlphaComponent(0.5)
        
        cell.playerProgress.backgroundColor = UIColor.blackColor()
        
        
        return cell
    }
    
    //MARK: Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
