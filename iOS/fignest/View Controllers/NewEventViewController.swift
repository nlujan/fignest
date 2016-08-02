//
//  NewEventViewController.swift
//  fignest
//
//  Created by Naim on 3/5/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

class NewEventViewController: UIViewController, CLLocationManagerDelegate {
    
    
    //MARK: Properties
    
    let userID: String = NSUserDefaults.standardUserDefaults().stringForKey("ID")!
    
    @IBOutlet var friendsLabel: UILabel!
    @IBOutlet var friendsIcon: UIImageView!
    
    @IBOutlet var addFriendsView: UIView!
    
    var names:[String] = []
    var selectedNames:[String] = []
    
    var contacts = [NWSTokenContact]()
    var selectedContacts = [NWSTokenContact]()
    
    var eventData: Event!
    var nameDict: [String: String] = [:]
    
    @IBOutlet var locationBtn: UIButton!
    @IBOutlet var locationActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var foodTypeTextField: UITextField!
    
    let locationManager = CLLocationManager()
    
    //MARK: Actions
    @IBAction func addFriendsPressed(sender: AnyObject) {
        
        print("pressed!!!!!")
        
        performSegueWithIdentifier("addFriendsSegue", sender: nil)
    }
    
    @IBAction func unwindAddFriendsView(unwindSegue: UIStoryboardSegue){
    
        if(unwindSegue.sourceViewController.isKindOfClass(AddFriendsViewController)) {
            let view: AddFriendsViewController = unwindSegue.sourceViewController as! AddFriendsViewController
            
            selectedContacts = view.selectedContacts
            contacts = view.contacts
            
            if selectedContacts.count == 0 {
                friendsIcon.image = UIImage(named: "ic_add_circle_outline_white")
                //friendsIcon.image = friendsIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                //friendsIcon.tintColor = StyleManager().primaryColor
                
                friendsLabel.text = "Add friends"
                
                //friendsLabel.textColor = UIColor(red:0.784, green:0.78, blue:0.8, alpha:1)
            } else {
                friendsIcon.image = UIImage(named: "ic_mode_edit_white")
                //friendsIcon.image = friendsIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                //friendsIcon.tintColor = StyleManager().primaryColor
                
                friendsLabel.text = "\(selectedContacts.count) Friend(s) Added"
                
                //friendsLabel.textColor = UIColor.blackColor()
            }
        }
    }

    @IBAction func createFig(sender: AnyObject) {
        
        var nilInputs: [String] = []
        
        if (titleTextField.text! == "") {
            nilInputs.append("title")
        }
        
        if (locationTextField.text! == "") {
            nilInputs.append("location")
        }
        
        if (selectedContacts.count == 0) {
            nilInputs.append("friends")
        }
        
        if (nilInputs.count > 0) {
            presentErrorView(nilInputs)
            
        } else {
            
            var userIDList:[String] = []
            userIDList.append(self.userID)
            
            for contact in selectedContacts {
                userIDList.append(nameDict[contact.name]!)
            }
            
            createEvent(titleTextField.text!, address: locationTextField.text!, users: userIDList, search: foodTypeTextField.text!)
        }
    }
    
    @IBAction func getUserLocation(sender: AnyObject) {
        locationBtn.hidden = true
        locationActivityIndicator.hidden = false
        locationActivityIndicator.startAnimating()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK: API Functions
    
    private func createEvent(title: String, address: String, users: [String], search: String) {
        APIRequestHandler().createEvent(title, address: address, users: users, search: search, callback: { ( jsonDict: JSON) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                
                self.eventData = Event(data: jsonDict)
                
                self.performSegueWithIdentifier("showPreWaiting", sender: nil)
            })
        })
    }
    
    private func getAllUsers() {
        APIRequestHandler().getAllUsers({ ( jsonArray: JSON) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                
                var nameList = [String]()
                var nameDict = [String:String]()
                for (_,user):(String, JSON) in jsonArray {
                    let name = user["displayName"].stringValue
                    let id = user["_id"].stringValue
                    
                    if id != self.userID {
                        nameList.append(name)
                        nameDict[name] = id
                    }
                }
                self.names = nameList
                self.nameDict = nameDict;
            })
        })
    }
    
    //MARK: Functions
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func presentErrorView(nilInputs: [String]) {
        let invalidInputString = "Please enter: " + nilInputs.joinWithSeparator(", ")
        
        let attributedString = NSAttributedString(string: "Invalid input!", attributes: [
            NSFontAttributeName : UIFont.systemFontOfSize(15), //your font here,
            NSForegroundColorAttributeName : UIColor.redColor()
            ])
        
        let alert = UIAlertController(title: "Invalid input!", message: invalidInputString, preferredStyle: .Alert)
        
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        self.presentViewController(alert, animated: true){}
    }
    
    //MARK: Location Manager Functions
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] 

        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) in

            if error != nil {
                print(error)
            } else {
                let pm = CLPlacemark(placemark: placemarks?[0] as CLPlacemark!)
                self.displayLocationInfo(pm)
            }
        
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        //stop updating location to save battery life
        
        
        if (placemark.subThoroughfare != nil) {
            let address = "\(placemark.subThoroughfare!) \(placemark.thoroughfare!), \(placemark.locality!), \(placemark.administrativeArea!)"
            
            locationTextField.text = address
            
            locationBtn.hidden = false
            locationActivityIndicator.hidden = true
            locationActivityIndicator.stopAnimating()
            
            
            //moved to bottom
            locationManager.stopUpdatingLocation()
        }
    }
    
    //MARK: Override Functions
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //IQKeyboardManager.sharedManager().enable = true
        
        getAllUsers()
        
        locationActivityIndicator.hidden = true
        
        
        //        self.tableView.layer.borderWidth = 0.5
        //        self.tableView.layer.borderColor = UIColor.grayColor().CGColor
        //
        //        self.tableView.layer.cornerRadius = 8.0
        
        
        // tapping outside screen clear keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        let origImage = UIImage(named: "CurrentLocation")
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        locationBtn.setImage(tintedImage, forState: .Normal)
        locationBtn.tintColor = UIColor.blueColor()
        

        friendsIcon.image = UIImage(named: "ic_add_circle_outline_white")
        
        addFriendsView.layer.borderWidth = 0.5
        addFriendsView.layer.borderColor = UIColor(red:0.784, green:0.78, blue:0.8, alpha:1).CGColor
        
        addFriendsView.layer.cornerRadius = 5
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
        
        if segue.identifier == "showPreWaiting" {
            let navController = segue.destinationViewController as! UINavigationController
            
            let viewController = navController.topViewController as! PreWaitingViewController
            
            viewController.eventData = self.eventData
            
        } else if segue.identifier == "addFriendsSegue" {
            let navController = segue.destinationViewController as! UINavigationController
            
            let viewController = navController.topViewController as! AddFriendsViewController
            
            if self.contacts.count == 0 {
                viewController.names = self.names
            }
            
            viewController.contacts = self.contacts
            
            viewController.selectedContacts = self.selectedContacts
            
            
        }
        
    }

}
