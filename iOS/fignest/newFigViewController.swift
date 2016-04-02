//
//  newFigViewController.swift
//  fignest
//
//  Created by Naim on 3/5/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import CoreLocation

class newFigViewController: UIViewController, CLLocationManagerDelegate, CLTokenInputViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let userID: String = NSUserDefaults.standardUserDefaults().stringForKey("ID")!
    //var userEventID: String = ""
    
    var names:[String] = []
    var filteredNames:[String] = []
    var selectedNames:[String] = []
    
    var eventData: FigEvent!
    
    var nameDict: [String: String] = [:]
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tokenInputView: CLTokenInputView!
    @IBOutlet var locationBtn: UIButton!
    @IBOutlet var locationActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var foodTypeTextField: UITextField!
    
    let locationManager = CLLocationManager()
    

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
            
            let invalidInputString = "Please enter: " + nilInputs.joinWithSeparator(", ")
            
            let attributedString = NSAttributedString(string: "Invalid input!", attributes: [
                NSFontAttributeName : UIFont.systemFontOfSize(15), //your font here,
                NSForegroundColorAttributeName : UIColor.redColor()
                ])
            
            let alert = UIAlertController(title: "Invalid input!", message: invalidInputString, preferredStyle: .Alert)
            
            alert.setValue(attributedString, forKey: "attributedTitle")
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
        } else {
            
            var userIDList:[String] = []
            userIDList.append(self.userID)
            
            for name in selectedNames {
                userIDList.append(nameDict[name]!)
            }
            
            print("\(locationTextField.text!)")
            print(locationTextField.text == nil)
            print("\(titleTextField.text!)")
            print("\(foodTypeTextField.text!)")
            print(userIDList)
            
            APIRequestHandler.sharedInstance.createNewFig(titleTextField.text!, address: locationTextField.text!, users: userIDList, search: foodTypeTextField.text!, callback: { ( dataDict: NSDictionary) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    //var dataArray = self.prefs.objectForKey("figInvitations") as! NSArray
                 
                    
//                self.userEventID = dataDict["_id"] as! String
//                print(dataDict["_id"] as! String)
                    
                self.eventData = FigEvent(data: dataDict)
                    
                self.performSegueWithIdentifier("showPreWaiting", sender: nil)
                    
                })
            })
            
        }
        

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIRequestHandler.sharedInstance.getAllUsers({ ( dataArray: NSArray) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                //var dataArray = self.prefs.objectForKey("figInvitations") as! NSArray
                
                
                var nameList: [String] = []
                var nameDict: [String: String] = [:]
                for user in dataArray {
                    var name = user["displayName"] as! String
                    var id = user["_id"] as! String
                    
                    if id != self.userID {
                        nameList.append(name)
                        nameDict[name] = id
                    }
                    
                }
                
                self.names = nameList;
                
                self.nameDict = nameDict;
                
                print(nameDict)
                
            })
            
        })
        
        
        locationActivityIndicator.hidden = true
        
        
//        self.tokenInputView.layer.borderWidth = 0.5
//        self.tokenInputView.layer.borderColor = UIColor.grayColor().CGColor
//        
//        self.tokenInputView.layer.cornerRadius = 8.0
        
        
        // tapping outside screen clear keyboard
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
//        view.addGestureRecognizer(tap)
        
        let origImage = UIImage(named: "CurrentLocation");
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        locationBtn.setImage(tintedImage, forState: .Normal)
        locationBtn.tintColor = UIColor.blueColor()

    
        
        self.tokenInputView.placeholderText = "Enter a name ";
        //self.tokenInputView.accessoryView = self.contactAddButton();
        self.tokenInputView.drawBottomBorder = true;
        self.tokenInputView.delegate = self
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.tableView.hidden = true;
        
    }
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var userLocation: CLLocation = locations[0] as! CLLocation

        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) in

            if error != nil {
                print(error)
            }
            else {
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
            
            
            print(address)
            
            
            locationTextField.text = address
            
            locationBtn.hidden = false
            locationActivityIndicator.hidden = true
            locationActivityIndicator.stopAnimating()
            
            
            //moved to bottom
            locationManager.stopUpdatingLocation()
        }

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
 
    
    
    
    
    
    //MARK: CLTokenInputViewDelegate
    
    func tokenInputView(aView: CLTokenInputView, didChangeText text: String) {
        // print("tokenInputView(didChangeText text:\(text))")
        if text == "" {
            self.filteredNames = []
            self.tableView.hidden = true
        }
        else {
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
        }
        else {
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
    



}
