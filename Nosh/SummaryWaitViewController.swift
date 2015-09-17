//
//  SummaryWaitViewController.swift
//  Nosh
//
//  Created by Michael Kolyadintsev on 03.07.15.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import UIKit
import Darwin
import Foundation

class SummaryWaitViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var order: PFObject!
    var card: STPCard!    
    var vendorItems: [PFObject]!

    @IBAction func withdrawDeliveryButton(sender: UIButton) {
        order.deleteInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                NSLog("", "Order withdraw made")
                // The object has been saved.
                self.performSegueWithIdentifier("goto_map", sender: self)
            } else {
                // There was a problem, check error.description
                self.showError("Order withdrawing error", error: error!)
            }
        })
        self.performSegueWithIdentifier("goto_map", sender: self)
    }
    
    override func viewWillDisappear(animated: Bool) {
//        let savedData = PFObject(className:"savedData")
//        savedData["order"] = self.order
//        savedData["card"] = self.card
//        savedData["vendorItems"] = self.vendorItems
//        savedData.pin()
//        PFUser.currentUser().pinWithName("lastUser")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    override func viewWillAppear(animated: Bool) {
//        //NSLog("%@", "-1")
//        let query = PFQuery(className:"savedData")
//        //NSLog("%@", "0")
//        query.fromLocalDatastore()
//        var object : PFObject = PFObject.new()
//        var findresult: Bool = false
//        query.getFirstObjectInBackgroundWithBlock { (newObject:PFObject!, error: NSError!) -> Void in
//            if error == nil {
//                // The find succeeded.
//                // Do something with the found objects
//                object = newObject
//                findresult = true
//            } else {
//                // Log details of the failure
//                println("Error: \(error!) \(error!.userInfo!)")
//            }}
////        NSLog("%@", 1)
//        if (findresult) {
//            self.order = object["order"] as! PFObject
//            self.card = object["card"] as! STPCard
//            self.vendorItems = object["vendorItems"] as! [PFObject]
//            object.unpin()
//        }
////        NSLog("%@", 2)
        delay(3) {
            self.waitDelivery()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    private func waitDelivery () {
        self.showActivityIndicatory()
        let query = PFQuery(className: "Order")
        query.whereKey("objectId", equalTo: self.order.objectId)
        query.getObjectInBackgroundWithId(self.order.objectId) {
            (newOrder: PFObject?, error: NSError?) -> Void in
            if error == nil && newOrder != nil {
                var orderStatus = newOrder?.objectForKey("status") as! PFObject
                NSLog("%@", orderStatus)
                if orderStatus.objectId == Constant.OrderStatus.IN_DELIVERY {
                    self.performSegueWithIdentifier("goto_success", sender: self)
                }
            } else {
                println(error)
            }
        }
        for var i = 1; i<48; i++ {
            let query = PFQuery(className: "Order")
            query.whereKey("objectId", equalTo: self.order.objectId)
            query.getObjectInBackgroundWithId(self.order.objectId) {
                (newOrder: PFObject?, error: NSError?) -> Void in
                if error == nil && newOrder != nil {
                    var orderStatus = newOrder?.objectForKey("status") as! PFObject
                    if orderStatus.objectId == Constant.OrderStatus.IN_DELIVERY {
                        NSLog("%@", orderStatus)
                        self.performSegueWithIdentifier("goto_success", sender: self)
                    }
                } else {
                    println(error)
                }
            }
            sleep(5)
        }
        self.hideActivityIndicator()
        self.performSegueWithIdentifier("goto_fail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goto_success") {
            let navigationController = segue.destinationViewController as! UINavigationController
            var svc = navigationController.topViewController as! SummaryDelivererFoundViewController
            svc.order = self.order
            svc.card = self.card
            svc.vendorItems = self.vendorItems
        } else if (segue.identifier == "goto_fail") {
            let navigationController = segue.destinationViewController as! UINavigationController
            var svc = navigationController.topViewController as! SummaryWithdrawViewController
            svc.order = self.order
        }
//        else if (segue.identifier == "goto_map") {
//            order.deleteInBackgroundWithBlock({
//                (success: Bool, error: NSError?) -> Void in
//                if (success) {
//                    NSLog("", "Order withdraw made")
//                    // The object has been saved.
//                    self.performSegueWithIdentifier("goto_map", sender: self)
//                } else {
//                    // There was a problem, check error.description
//                    self.showError("Order withdrawing error", error: error!)
//                }
//            })
//        }
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
