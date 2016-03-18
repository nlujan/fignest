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

    @IBOutlet var loginButton: FBSDKLoginButton!
    let prefs = NSUserDefaults.standardUserDefaults()
    
    func takeUserToHomePage() {
        let homePage = self.storyboard?.instantiateViewControllerWithIdentifier("FigsTableViewController") as! FigsTableViewController
        
        let homePageNav = UINavigationController(rootViewController: homePage)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window!.rootViewController = homePageNav
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var titleText = NSAttributedString(string: "Continue with Facebook")
        loginButton.setAttributedTitle(titleText, forState: UIControlState.Normal)

        // Do any additional setup after loading the view.
        
        let accessToken = FBSDKAccessToken.currentAccessToken()
        
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            
            
            var name: String = prefs.stringForKey("userFBName")!
            
            print("token = \(accessToken.tokenString)")
            print("User ID = \(accessToken.userID)")
            print("User Name = \(name)")
            
            
            takeUserToHomePage()
            
        }
        
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            print("already logged in")
        }
        else {
            print("not logged in")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!){
        
        if(error != nil) {
            print(error.localizedDescription)
            return
        }
        
        if let userToken = result.token {
            //get user access token
            //let token:FBSDKAccessToken = result.token
            
            let userID = userToken.userID
            
            print("token = \(userToken.tokenString)")
            print("User ID = \(userID)")
            
            var username: String = "none"
            
            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,first_name"], tokenString: userToken.tokenString, version: nil, HTTPMethod: "GET")
            req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
                if(error == nil) {
                    //print("result \(result["name"]!)")
                    username = result["first_name"] as! String
                    self.prefs.setValue(username, forKey: "userFBName")
                    //print("result \(result["first_name"])")
                    //print(username)
                }
                else {
                    print("error \(error)")
                }
            })
            
            prefs.setValue(userID, forKey: "userFBID")
            //print(username)
           
            
            
            takeUserToHomePage();
            
        }
        
    }
    

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        let loginManager = FBSDKLoginManager();
        loginManager.logOut()
        print("User is logged out")
    
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
