//
//  ResultsViewController.swift
//  fignest
//
//  Created by Naim on 3/24/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
    
    //MARK: Properties
    
    var eventData: FigEvent!
    var resultData: NSDictionary!
    @IBOutlet var resultName: UILabel!
    
    
    //MARK: Actions
    
    @IBAction func goToYelpPage(sender: AnyObject) {
        if let url = NSURL(string: resultData["urls"]!["mobile"] as! String){
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func homeButtonPressed(sender: AnyObject) {
        takeUserToHomePage()
    }
    
    
    //MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFinalResult()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: Generic functions
    
    func takeUserToHomePage() {
        let homePage = self.storyboard?.instantiateViewControllerWithIdentifier("EventsTableViewController") as! EventsTableViewController
        
        let homePageNav = UINavigationController(rootViewController: homePage)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window!.rootViewController = homePageNav
    }
    
    private func getFinalResult()  {
        APIRequestHandler.sharedInstance.getSolution(eventData.id, callback: { ( dataDict: NSDictionary) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                print(dataDict)
                self.resultData = dataDict
                print("We did it!!")
                self.resultName.text = dataDict["name"] as? String
                
            })
            
        })
        
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
