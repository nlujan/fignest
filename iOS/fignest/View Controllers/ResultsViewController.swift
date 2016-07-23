//
//  ResultsViewController.swift
//  fignest
//
//  Created by Naim on 3/24/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import SwiftyJSON

class ResultsViewController: UIViewController {
    
    //MARK: Properties
    
    var eventData: Event!
    var resultData: JSON = []
    @IBOutlet var resultName: UILabel!
    
    
    //MARK: Actions
    
    @IBAction func goToYelpPage(sender: AnyObject) {
        if let url = NSURL(string: resultData["urls"]["mobile"].stringValue) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func homeButtonPressed(sender: AnyObject) {
        NavigationUtil().takeUserToHomePage(self.storyboard)
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
    
    private func getFinalResult()  {
        APIRequestHandler().getEventSolution(eventData.id, callback: { ( jsonDict: JSON) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.resultData = jsonDict
                self.resultName.text = jsonDict["name"].stringValue
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
