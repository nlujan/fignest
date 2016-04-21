//
//  NewEventViewController.swift
//  fignest
//
//  Created by Naim on 3/5/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import CoreLocation

class NewEventViewController: UIViewController, CLLocationManagerDelegate, CLTokenInputViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    //MARK: Properties
    
    let userID: String = NSUserDefaults.standardUserDefaults().stringForKey("ID")!
    
    var names:[String] = []
    var filteredNames:[String] = []
    var selectedNames:[String] = []
    
    var eventData: Event!
    var nameDict: [String: String] = [:]
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tokenInputView: CLTokenInputView!
    
    @IBOutlet var locationBtn: UIButton!
    @IBOutlet var locationActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var foodTypeTextField: UITextField!
    
    let locationManager = CLLocationManager()
    
    //MARK: Actions

    @IBAction func createFig(sender: AnyObject) {
        
        var nilInputs: [String] = []
        
        if (titleTextField.text! == "") {
            nilInputs.append("title")
        }
        
        if (locationTextField.text! == "") {
            nilInputs.append("location")
        }
        
        if (selectedNames == []) {
            nilInputs.append("friends")
        }
        
        if (nilInputs.count > 0) {
            
            presentErrorView(nilInputs)
            
        } else {
            
            var userIDList:[String] = []
            userIDList.append(self.userID)
            
            for name in selectedNames {
                userIDList.append(nameDict[name]!)
            }
            
            createNewFig(titleTextField.text!, address: locationTextField.text!, users: userIDList, search: foodTypeTextField.text!)
            
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
    
    private func createNewFig(title: String, address: String, users: [String], search: String) {
        APIRequestHandler().createNewFig(title, address: address, users: users, search: search, callback: { ( dataDict: NSDictionary) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                
                self.eventData = Event(data: dataDict)
                
                self.performSegueWithIdentifier("showPreWaiting", sender: nil)
                
            })
        })
    }
    
    private func getAllUsers() {
        APIRequestHandler().getAllUsers({ ( dataArray: NSArray) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                
                var nameList: [String] = []
                var nameDict: [String: String] = [:]
                for user in dataArray {
                    let name = user["displayName"] as! String
                    let id = user["_id"] as! String
                    
                    if id != self.userID {
                        nameList.append(name)
                        nameDict[name] = id
                    }
                }
                self.names = nameList;
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
        alert.view.tintColor = StyleManager().primaryColor
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
    
    //MARK: CLTokenInputViewDelegate
    
    func tokenInputView(aView: CLTokenInputView, didChangeText text: String) {
        // print("tokenInputView(didChangeText text:\(text))")
        if text == "" {
            self.filteredNames = []
            self.tableView.hidden = true
        } else {
            let predicate:NSPredicate = NSPredicate(format: "self contains[cd] %@", argumentArray: [text])
            self.filteredNames = self.names.filter { predicate.evaluateWithObject($0) }
            self.tableView.hidden = false
        }
        self.tableView.reloadData()
    }
    
    func tokenInputView(aView:CLTokenInputView, didAddToken token:CLToken) {
        self.selectedNames.append(token.displayText)
    }
    
    func tokenInputView(aView:CLTokenInputView, didRemoveToken token:CLToken) {
        let idx:Int? = self.selectedNames.indexOf(token.displayText)
        self.selectedNames.removeAtIndex(idx!)
    }
    
    func tokenInputView(aView: CLTokenInputView, tokenForText text: String) -> CLToken? {
        //print("tokenInputView(tokenForText)")
        if self.filteredNames.count > 0 {
            let matchingName:String = self.filteredNames[0]
            let match:CLToken = CLToken()
            match.displayText = matchingName
            match.context = nil
            return match
        }
        return nil
    }
    
    func tokenInputViewDidEndEditing(aView: CLTokenInputView) {
        aView.accessoryView = nil
    }
    
    func tokenInputViewDidBeginEditing(aView: CLTokenInputView) {
        //aView.accessoryView = self.contactAddButton()
        self.view.layoutIfNeeded()
    }
    
    func tokenInputView(aView:CLTokenInputView, didChangeHeightTo height:CGFloat) {
        
    }
    
    //MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRowsInSection \(self.filteredNames.count)")
        
        return self.filteredNames.count
    }
    
    
    func tableView(aTableView: UITableView, cellForRowAtIndexPath anIndexPath: NSIndexPath) -> UITableViewCell {
        //print("cellForRowAtIndexPath")
        
        let cell = aTableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: anIndexPath)
        let name:String = self.filteredNames[anIndexPath.row]
        cell.textLabel!.text = name
        
        //print("name = \(name)  cell=\(cell)")
        if self.selectedNames.contains(name) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(aTableView: UITableView, didSelectRowAtIndexPath anIndexPath: NSIndexPath) {
        aTableView.deselectRowAtIndexPath(anIndexPath, animated: true)
        let name:String = self.filteredNames[anIndexPath.row]
        let token:CLToken = CLToken()
        token.displayText = name
        token.context = nil
        if self.tokenInputView.isEditing() {
            self.tokenInputView.addToken(token)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    //MARK: Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllUsers()
        
        locationActivityIndicator.hidden = true
        
        
        //        self.tableView.layer.borderWidth = 0.5
        //        self.tableView.layer.borderColor = UIColor.grayColor().CGColor
        //
        //        self.tableView.layer.cornerRadius = 8.0
        
        
        // tapping outside screen clear keyboard
        //        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        //        view.addGestureRecognizer(tap)
        
        let origImage = UIImage(named: "CurrentLocation");
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        locationBtn.setImage(tintedImage, forState: .Normal)
        locationBtn.tintColor = UIColor.blueColor()
        
        
        
        self.tokenInputView.placeholderText = "Enter a name ";
        self.tokenInputView.drawBottomBorder = true;
        self.tokenInputView.delegate = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.hidden = true;
        
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
        
        if (segue.identifier == "showPreWaiting") {
            let navController = segue.destinationViewController as! UINavigationController
            
            let viewController = navController.topViewController as! PreWaitingViewController
            
            viewController.eventData = self.eventData
            
        }
        
    }

}
