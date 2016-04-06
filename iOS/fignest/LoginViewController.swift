//
//  LoginViewController.swift
//  fignest
//
//  Created by Naim on 3/4/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    // MARK: Properties
    @IBOutlet var loginButton: FBSDKLoginButton!
    
    
    // MARK: Functions
    func takeUserToHomePage() {
        let homePage = self.storyboard?.instantiateViewControllerWithIdentifier("FigsTableViewController") as! FigsTableViewController
        let homePageNav = UINavigationController(rootViewController: homePage)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window!.rootViewController = homePageNav
    }
    
    func addUser(name: String, fbID: String, email: String) {
        APIRequestHandler.sharedInstance.addUserToDatabase(name, fbID: fbID, email: email, callback: { ( dataDict: NSDictionary) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                
                let userID = dataDict["_id"] as! String
                print(userID)
                
                //save value of ID
                NSUserDefaults.standardUserDefaults().setValue(userID, forKey: "ID")
                self.takeUserToHomePage();
            })
        })
        
    }
    
    //MARK: FB Login Button Functions
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!){
        
        if(error != nil) {
            print(error.localizedDescription)
            return
        }
        
        if let userToken = result.token {
            let userID = userToken.userID as String
            
            print("token = \(userToken.tokenString)")
            print("User ID = \(userID)")
            
            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,email,first_name,last_name"], tokenString: userToken.tokenString, version: nil, HTTPMethod: "GET")
            req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
                if(error == nil) {
                    let name = "\(result["first_name"] as! String) \(result["last_name"] as! String)"
                    let fbID = result["id"] as! String
                    let email = result["email"] as! String
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    
                    // save values in userDefaults
                    userDefaults.setValue(name, forKey: "userFBName")
                    userDefaults.setValue(fbID, forKey: "userFBID")
                    
                    
                    //post user to database
                    self.addUser(name, fbID: fbID, email: email)
                    
                    
                }
                else {
                    print("error: \(error)")
                }
            })
            
        }
        
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        let loginManager = FBSDKLoginManager();
        loginManager.logOut()
        print("User is logged out")
        
    }
    
    
    // MARK: Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleText = NSAttributedString(string: "Continue with Facebook")
        loginButton.setAttributedTitle(titleText, forState: UIControlState.Normal)
        
        let accessToken = FBSDKAccessToken.currentAccessToken()
        
        if(accessToken != nil) {
            takeUserToHomePage()
        }
        
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
