//
//  NavigationUtil.swift
//  fignest
//
//  Created by Naim on 4/22/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

struct NavigationUtil {
    
    func takeUserToHomePage(storyboard: UIStoryboard?) {
        let homePage = storyboard?.instantiateViewControllerWithIdentifier("EventsTableViewController") as! EventsTableViewController
        let homePageNav = UINavigationController(rootViewController: homePage)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window!.rootViewController = homePageNav
    }
    
    func takeUserToLoginPage(storyboard: UIStoryboard?) {
        let loginPageController = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window!.rootViewController = loginPageController
    }


}
