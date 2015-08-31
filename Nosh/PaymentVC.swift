//
//  PaymentVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 02/03/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation

class PaymentVC: UIViewController, PTKViewDelegate {
    
    @IBOutlet weak var payButton: UIBarButtonItem!
    var paymentView: PTKView?
    var order: PFObject!
    var vendorItems: [PFObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paymentView = PTKView(frame: CGRectMake(15, 20, 290, 55))
        paymentView?.center = view.center
        paymentView?.delegate = self
        view.addSubview(paymentView!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goto_confirmed") {
            let navigationController = segue.destinationViewController as! UINavigationController
            var svc = navigationController.topViewController as! ConfirmedVC
            svc.order = self.order
        }
    }
    
    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        payButton!.enabled = valid
    }
    
    @IBAction func createToken() {
        let card = STPCard()
        card.number = paymentView!.card.number
        card.expMonth = paymentView!.card.expMonth
        card.expYear = paymentView!.card.expYear
        card.cvc = paymentView!.card.cvc
        
        STPAPIClient.sharedClient().createTokenWithCard(card, completion: { (token: STPToken!, error: NSError!) -> Void in
            if(error != nil){
                self.showError("Payment Failed!", error: error)
            } else {
                self.handleToken(token)
            }
        })
    }
    
    func handleToken(token: STPToken!) {
        PFCloud.callFunctionInBackground("pay", withParameters: ["amount" : self.order["totalAmount"], "tokenId": token.tokenId]) { (result:AnyObject!, error: NSError!) -> Void in
            if(error == nil){
                self.order["user"] = PFUser.currentUser()
                self.order["status"] = PFObject(withoutDataWithClassName: "OrderStatus", objectId: Constant.OrderStatus.UNFILLED)
                var relation = self.order.relationForKey("items")
                for object in self.vendorItems {
                    var orderItem = PFObject(className: "OrderItem")
                    orderItem["price"] = object["price"]
                    orderItem["count"] = object["count"]
                    orderItem["title"] = object["title"]
                    orderItem["detail"] = object["detail"]
                    orderItem.save()
                    relation.addObject(orderItem)
                    object.removeObjectForKey("count")
                }
                self.order.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                    if error == nil {
                        self.performSegueWithIdentifier("goto_confirmed", sender: self)
                    } else {
                        self.showError("Failed!", error: error)
                    }
                })
                
            } else {
                self.showError("Payment Failed!", error: error)
            }
        }
    }
    
}
