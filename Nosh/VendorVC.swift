//
//  ViewController.swift
//  Nosh
//
//  Created by Muhammad Javeed on 16/01/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import UIKit
class VendorVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var locationManager:CLLocationManager!
    var currLocation : CLLocationCoordinate2D?
    var gmaps: GMSMapView?
    var objects: [PFObject]!
    var deliverers: [PFObject]!
    var delivererMarkers:[GMSMarker] = []
    var selectedIndex : Int?
    var buttonReload:UIButton?
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 89
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        buttonReload = UIButton(frame: CGRectMake(10, 80, 80, 30))
        buttonReload!.backgroundColor = UIColor(hex: "39b2ff", alpha: 1.0)
        buttonReload!.titleLabel?.adjustsFontSizeToFitWidth
        buttonReload!.setTitle("Reload", forState: UIControlState.Normal)
        buttonReload!.addTarget(self, action: "addDelivererMarkers:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonReload!.tag = 22
        buttonReload?.titleLabel?.font = UIFont(name: "COCOGOOSE", size: 14)
        buttonReload?.hidden = true
        
        let config = PFConfig.currentConfig()
        if(config != nil && config["gms_key"] != nil){
            self.initVC()
        } else {
            self.showActivityIndicatory()
            PFConfig.getConfigInBackgroundWithBlock{
                (config: PFConfig!, error: NSError!) -> Void in
                self.hideActivityIndicator()
                if(error == nil){
                    Util.configure(config)
                    self.initVC()
                    self.gmaps!.addSubview(self.buttonReload!)
                } else {
                    self.showError("Error", error: error)
                }
            }
        }
        
        
        var attr = NSDictionary(object: UIFont(name: "COCOGOOSE", size: 15.0)!, forKey: NSFontAttributeName)
        self.segmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject], forState: UIControlState.Normal)
        
    }
    
    func initVC(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest        
        triggerLocationServices()
        
        var target: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 38.90748, longitude: -77.07000)
        var camera: GMSCameraPosition = GMSCameraPosition(target: target, zoom: 15, bearing: 0, viewingAngle: 0)
        
        
        
        gmaps = GMSMapView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        if (gmaps != nil) {
            gmaps!.myLocationEnabled = true
            gmaps!.camera = camera
            gmaps!.delegate = self
            gmaps!.settings.myLocationButton = true
            gmaps!.settings.zoomGestures = true
            
            self.view.addSubview(gmaps!)
            gmaps!.hidden = true;
        }
    }
    
    func triggerLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            if self.locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                locationManager.requestWhenInUseAuthorization()
            } else {
                startUpdatingLocation()
            }
        }
    }
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            startUpdatingLocation()
            queryForTable()
        } else if status == .Denied || status == .Restricted {
            alertLocationFailed()
            queryForTable()
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects == nil ? 0 : objects.count
    }
    
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VendorCell", forIndexPath: indexPath) as! VendorTableViewCell
        var object = self.objects[indexPath.row]
        cell.name.text = object.valueForKey("name") as? String
        cell.address.text = Util.getAddress(object)
        var location = object.valueForKey("location") as? PFGeoPoint
        if let userLoc = currLocation {
            if let queryLoc = location {
                var distance = queryLoc.distanceInMilesTo(PFGeoPoint(latitude: userLoc.latitude, longitude: userLoc.longitude)) as Double
                cell.distance.text = String(format:"%.1f", distance) + " mi"
            }
        } else {
            cell.distance.text = ""
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goto_item") {
            let svc = segue.destinationViewController as! VendorItemVC
            if(self.selectedIndex != nil){
                svc.vendor = self.objects[self.selectedIndex!] as PFObject
            } else {
                let row = self.tableView.indexPathForSelectedRow()!.row
                svc.vendor = self.objects[row] as PFObject
            }
        }
    }
    
    func queryForTable() {
        let query = PFQuery(className: "Vendor")
        if let queryLoc = currLocation {
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: queryLoc.latitude, longitude: queryLoc.longitude))
        }
        self.showActivityIndicatory()
        query.findObjectsInBackgroundWithBlock{
            (objects: [AnyObject]!, error: NSError!) -> Void in
            self.hideActivityIndicator()
            if error == nil {
                self.objects = objects as! [PFObject]!
                self.tableView.reloadData()
                self.addMarkers()
            } else {
                self.showError("Failed!", error: error)
            }
        }
    }
    
    private func addMarkers(){
        if(self.objects != nil && self.gmaps != nil){
            for var index = 0; index < self.objects.count; ++index{
                var object = self.objects[index]
                var location = object.valueForKey("location") as? PFGeoPoint
                if (location != nil) {
                    var position = CLLocationCoordinate2DMake(location!.latitude, location!.longitude)
                    var marker = GMSMarker(position: position)
                    marker.title = object.valueForKey("name") as? String
                    marker.snippet = Util.getAddress(object)
                    marker.userData = index
                    marker.appearAnimation = kGMSMarkerAnimationPop
                    marker.map = gmaps
                }
            }
        }
    }
    
    func addDelivererMarkers(sender:UIButton!) {
        NSLog("", "AddDelivererMarkers called")
        if(self.gmaps != nil){
            if delivererMarkers.count > 0 {
                for marker: GMSMarker in delivererMarkers {
                    marker.map = nil
                }
                delivererMarkers.removeAll(keepCapacity: false)
            }
            let query = PFQuery(className: "User")
            if let queryLoc = currLocation {
                query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: queryLoc.latitude, longitude: queryLoc.longitude))
            }
            query.findObjectsInBackgroundWithBlock{
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    self.deliverers = objects as! [PFObject]!
                    for var index = 0; index < self.deliverers.count; ++index{
                        var object = self.objects[index]
                        var location = object.valueForKey("location") as? PFGeoPoint
                        if (location != nil) {
                            var position = CLLocationCoordinate2DMake(location!.latitude, location!.longitude)
                            var marker = GMSMarker(position: position)
                            marker.title = object.valueForKey("name") as? String
                            marker.snippet = object.valueForKey("phone") as? String
                            marker.userData = index
                            marker.appearAnimation = kGMSMarkerAnimationPop
                            marker.map = self.gmaps
                            self.delivererMarkers.append(marker)
                        }
                    }

                } else {
                    self.showError("Failed!", error: error)
                }
            }

        }
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        self.selectedIndex = marker.userData as? Int
       self.performSegueWithIdentifier("goto_item", sender: self)
    }

    private func alertLocationFailed() {
        let alertController = UIAlertController(
            title: "Turn Location Services On",
            message: "Please turn on location services to allow Nosh to determine your location",
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(openAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    var firstLocationFailed = false
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if(!firstLocationFailed){
            firstLocationFailed = true
            queryForTable()
 //           alertLocationFailed()
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //locationManager.stopUpdatingLocation()
        if(locations.count > 0){
            let location = locations[0] as! CLLocation
            currLocation = location.coordinate
            
//            moveCameraTo(location.coordinate)
        }
        if Util.isDelivererMode() {
            var userLocation = PFGeoPoint.new()
            userLocation.latitude = locationManager.location.coordinate.latitude
            userLocation.longitude = locationManager.location.coordinate.longitude
            PFUser.currentUser().setValue(userLocation, forKey: "location")
        }
        //queryForTable()
    }

    func moveCameraTo(location: CLLocationCoordinate2D){
        var target: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        var camera: GMSCameraPosition = GMSCameraPosition(target: target, zoom: 16, bearing: 0, viewingAngle: 0)
        if gmaps != nil {
            gmaps!.camera = camera
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuTapped(sender : UIBarButtonItem) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    @IBAction func startNewOrderController(segue:UIStoryboardSegue) {}
    
    @IBAction func indexChanged(sender:UISegmentedControl){
        self.selectedIndex = nil
        switch sender.selectedSegmentIndex{
            case 0:
                gmaps?.hidden = false
            buttonReload?.hidden = false
            case 1:
                gmaps?.hidden = true
            buttonReload?.hidden = true
            default:
                break;
        }
    }
}

