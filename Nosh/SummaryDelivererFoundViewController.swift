//
//  SummaryDelivererFoundViewController.swift
//  Nosh
//
//  Created by Michael Kolyadintsev on 03.07.15.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import UIKit

class SummaryDelivererFoundViewController: UIViewController {
    
    var order: PFObject!
    var card: STPCard!
    var vendorItems: [PFObject]!
    
    @IBAction func callDelivererButton(sender: UIButton) {
        var deliverer: PFObject!
        
        let query = PFQuery(className: "Order")
        query.whereKey("objectId", equalTo: order.objectId)
        query.getObjectInBackgroundWithId(order.objectId) {
            (newOrder: PFObject?, error: NSError?) -> Void in
            if error == nil && newOrder != nil {
                deliverer = newOrder?.objectForKey("assignedTo") as! PFObject
            } else {
                print(error)
            }
        }
        let delivererPhone = deliverer["phone"] as! String
        self.callNumber(delivererPhone)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string:"tel://"+"\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goto_checkout") {
            for object in self.vendorItems {
                object.removeObjectForKey("count")
            }
            let navigationController = segue.destinationViewController as! UINavigationController
            var svc = navigationController.topViewController as! ConfirmedVC
            svc.order = self.order
        }
    }
    
    
    @IBAction func checkoutBtn(sender: UIButton) {
        self.createToken()
    }
    
    
    func createToken() {
        self.showActivityIndicatory()
        STPAPIClient.sharedClient().createTokenWithCard(self.card, completion: { (token: STPToken!, error: NSError!) -> Void in
            if(error != nil){
                self.hideActivityIndicator()
                self.showError("Payment Failed!", error:error)
            } else {
                self.handleToken(token)
            }
        })
    }
    
    func handleToken(token: STPToken!) {
        var test = false
        #if DEBUG
            test = true
        #endif
        let vendor = self.order["vendor"] as! PFObject;
        PFCloud.callFunctionInBackground("pay", withParameters: ["amount" : String(format: "%.2f", order["totalAmount"] as! Float), "tokenId": token.tokenId, "test":test, "metadata":["userEmail":PFUser.currentUser().email, "vendorName":vendor["name"]]]) {
            (result:AnyObject!, error: NSError!) -> Void in
            if(error == nil){
                self.navigationItem.hidesBackButton = true
                self.order["user"] = PFUser.currentUser()
                self.order["status"] = PFObject(withoutDataWithClassName: "OrderStatus", objectId: Constant.OrderStatus.UNFILLED)
                var relation = self.order.relationForKey("items")
                for object in self.vendorItems {
                    var orderItem = PFObject(className: "OrderItem")
                    orderItem["price"] = object["price"]
                    orderItem["count"] = object["count"]
                    orderItem["title"] = object["title"]
                    orderItem["detail"] = object["detail"]
                    relation.addObject(orderItem)
                    orderItem.save()
                }
                self.order.saveInBackgroundWithBlock({
                    (succeeded: Bool, error: NSError!) -> Void in
                    var paymentObject = PFObject(className: "Payment")
                    paymentObject["test"] = test
                    paymentObject["chargeId"] = result["id"]
                    paymentObject["amount"] = self.order["totalAmount"]
                    if error == nil {
                        self.hideActivityIndicator()
                        paymentObject["order"] = self.order
                        paymentObject.saveEventually()
                        PFCloud.callFunctionInBackground("sendNewOrderMail", withParameters: ["orderId": self.order.objectId], block: nil)
                        self.performSegueWithIdentifier("goto_checkout", sender: self)
                    } else {
                        PFCloud.callFunctionInBackground("refund", withParameters: ["chargeId": result["id"] as! String, "test": test, "amount" : String(format: "%.2f", self.order["totalAmount"] as! Float)]) {
                            (result:AnyObject!, error2: NSError!) -> Void in
                            self.hideActivityIndicator()
                            if (error2 == nil) {
                                self.showError("Failed!", message:"Something went wrong. Please try again")
                            } else {
                                self.showError("Failed!", message:"Something went wrong. Please contact to support for refund")
                                paymentObject["refund"] = true
                                paymentObject.saveEventually()
                            }
                        }
                    }
                })
            } else {
                self.hideActivityIndicator()
                self.showError("Payment Failed!", error:error)
            }
        }
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
