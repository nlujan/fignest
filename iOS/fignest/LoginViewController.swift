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
        
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            takeUserToHomePage()
            print("token = \(FBSDKAccessToken.currentAccessToken().tokenString)")
            print("User ID = \(FBSDKAccessToken.currentAccessToken().userID)")
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
            
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(userID, forKey: "userFBID")
            
            if let city = prefs.stringForKey("userCity"){
                print("The user has a city defined: " + city)
            }else{
                //Nothing stored in NSUserDefaults yet. Set a value.
                print("what is going on??")
                prefs.setValue("Berlin", forKey: "userCity")
            }
            
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
