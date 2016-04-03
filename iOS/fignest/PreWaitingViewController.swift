//
//  PreWaitingViewController.swift
//  fignest
//
//  Created by Naim on 3/13/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

class PreWaitingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    
    var users: [String] = []
    var eventData: FigEvent!
    
    @IBOutlet var waitingTable: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Actions
    
    @IBAction func preWaitingShowOptions(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Exit Fig", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("User Logged Out")
            
            self.takeUserToHomePage();
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        optionMenu.view.tintColor = StyleManager.sharedInstance.primaryColor
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("showGameView", sender: nil)
    }
    
    //MARK: Functions
    
    func takeUserToHomePage() {
        let homePage = self.storyboard?.instantiateViewControllerWithIdentifier("FigsTableViewController") as! FigsTableViewController
        
        let homePageNav = UINavigationController(rootViewController: homePage)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window!.rootViewController = homePageNav
    }
    
    //MARK: UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    //MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PreWaitingCell", forIndexPath: indexPath) as! PreWaitingCell
                
        cell.nameLabel.text = users[indexPath.row]
        
        return cell
    }
    
    //MARK: Override View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let prefs = NSUserDefaults.standardUserDefaults()
        let name: String = prefs.stringForKey("userFBName")!
        
        print(eventData);
        
        self.title = eventData.name.uppercaseString
        
        activityIndicator.startAnimating()
        
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
        
        
        if (segue.identifier == "showGameView") {
            let gameController = segue.destinationViewController as! GameViewController
            
            gameController.eventData = self.eventData
            
        }
        
        
    }


}
