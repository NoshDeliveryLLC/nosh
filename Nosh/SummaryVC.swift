//
//  SummaryVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 28/02/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation
class SummaryVC: UITableViewController, PTKViewDelegate{
    
    @IBOutlet weak var next: UIBarButtonItem!
    var order: PFObject!
    var vendorItems: [PFObject]!
    var paymentView: PTKView!
    var card: STPCard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paymentView = PTKView(frame: CGRectMake(10, 80, 250, 46))
        paymentView.delegate = self
        card = STPCard.new()
        self.order["user"] = PFUser.currentUser()
//        self.order["status"] = Constant.OrderStatus.UNFILLED
        
        //This code os the reason of the problem
        var query = PFQuery(className:"OrderStatus")
        query.getObjectInBackgroundWithId(Constant.OrderStatus.UNFILLED) {
            (status: PFObject?, error: NSError?) -> Void in
            if error == nil && status != nil {
                self.order["status"] = status
            } else {
                println(error)
            }
        }
        self.next.title = "Place order"
        
        self.tableView.estimatedRowHeight = 119
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goto_confirmed") {
//            for object in self.vendorItems {
//                object.removeObjectForKey("count")
//            }
//            let navigationController = segue.destinationViewController as! UINavigationController
//            var svc = navigationController.topViewController as! SummaryWaitViewController
            let destinationVC = segue.destinationViewController as! SummaryWaitViewController
            destinationVC.order = self.order
            destinationVC.card = self.card;
            destinationVC.vendorItems = self.vendorItems;
        } else if (segue.identifier == "goto_notes") {
            let navigationController = segue.destinationViewController as! UINavigationController
            var svc = navigationController.topViewController as! NotesVC
            svc.order = self.order
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vendorItems.count + 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row{
        case 0:
            return self.tableView.dequeueReusableCellWithIdentifier("SummaryCellHeading", forIndexPath: indexPath) as! UITableViewCell
        case self.vendorItems.count + 1:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("SummaryCellDetail", forIndexPath: indexPath) as! SummaryTableDetailCell
            
                cell.subTotal.text = String(format: "$%.2f", order["subTotal"] as! Float)
                cell.tax.text = String(format: "$%.2f", order["tax"] as! Float)
                cell.serviceCharges.text = String(format: "$%.2f", order["serviceCharges"] as! Float)
                cell.total.text = String(format: "$%.2f", order["totalAmount"] as! Float)
            return cell
        case self.vendorItems.count + 2:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("SummaryCellNotes", forIndexPath: indexPath) as! SummaryTableAddressCell
            var notes = self.order["notes"] as? String
            if(notes != nil && notes?.isEmpty == false){
                cell.editButton.setTitle("Edit", forState: UIControlState.Normal)
            } else {
                cell.editButton.setTitle("Add", forState: UIControlState.Normal)
            }
            cell.address.text = self.order["notes"] as? String
            return cell
        case self.vendorItems.count + 3:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("SummaryCellAddress", forIndexPath: indexPath) as! SummaryTableAddressCell
            let address = Util.getAddress()
            self.next.enabled = !address.isEmpty
            cell.address.text = address
            if(address.isEmpty == false){
                cell.editButton.setTitle("Edit", forState: UIControlState.Normal)
            } else {
                cell.editButton.setTitle("Add", forState: UIControlState.Normal)
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("SummaryCell", forIndexPath: indexPath) as! SummaryTableViewCell
            var object = self.vendorItems[indexPath.row - 1]
            cell.title.text = object.valueForKey("title") as? String
            var price = object.valueForKey("price") as? Float
            var count = object.valueForKey("count") as? Int
            if(price != nil && count != nil){
                var countText = count!.description
                var priceText = String(format: " x $%.2f", price!)
                var totalPrice = price! * Float(count!)
                cell.price.text = countText+priceText
            }
            return cell
        }
    }
    
    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
    }
    
    @IBAction func payTapped(sender : UITabBarItem) {
        var vendor = order["vendor"] as! PFObject
//        PFCloud.callFunction("NewOrder", withParameters: ["name": vendor["name"]])
        
        //Temp function because of parse.com cloud bugs. Production version my use parse.com cloud code (project folder/parse)
        let message = "New delivery job available from " .stringByAppendingString(vendor["name"] as! String)
        let data = [
            "alert" : message,
            "badge" : "Increment",
            "option" : "2"
        ]
        let push = PFPush()
        push.setChannel("Deliverer")
        push.setData(data)
        push.sendPush(NSErrorPointer())
        
        //Temp func end
        
        var title = "MAKE PAYMENT OF " + String(format: "$%.2f", order["totalAmount"] as! Float) as String
        
        var container = UIView(frame: CGRectMake(0, 0, 270, 140))
        
        var label = UILabel(frame: CGRectMake(10, 15, 250, 20))
        label.textAlignment = NSTextAlignment.Center
        label.text = title
        label.font = UIFont(name: "COCOGOOSE", size: 17)
        container.addSubview(label)
        
        var messageLabel = UILabel(frame: CGRectMake(10, 45, 250, 20))
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.text = "Enter your card information"
        messageLabel.font = UIFont(name: "Helvetica Neue Light", size: 18)
        messageLabel.textColor = UIColor(hex: "494949", alpha: 1.0)
        container.addSubview(messageLabel)
        
        container.addSubview(UITextField(frame: CGRectMake(10, 85, 250, 20)))
        messageLabel.becomeFirstResponder()
        container.addSubview(paymentView)
        
        var alert = CustomIOS7AlertView()
        alert.containerView = container
        alert.buttonTitles = ["Cancel", "Place order"]

        alert.onButtonTouchUpInside = {
            (alertView: CustomIOS7AlertView, buttonIndex: Int) -> Void in
            alertView.close()
            //Error happens here while saving the order
            if(buttonIndex == 1){
                self.next.enabled = false
                self.card.number = self.paymentView.card.number
                self.card.expMonth = self.paymentView.card.expMonth
                self.card.expYear = self.paymentView.card.expYear
                self.card.cvc = self.paymentView.card.cvc
                self.order.save()
                self.performSegueWithIdentifier("goto_confirmed", sender: self)
            }
            
        }
        alert.show({(status: Bool) -> Void in
            paymentView.becomeFirstResponder()
        })
        alert.setButtonEnabled(paymentView.isValid(), buttonName: "Place order")
        NSNotificationCenter.defaultCenter().addObserverForName("NotificationIdentifier", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
            alert.setButtonEnabled(self.paymentView.isValid(), buttonName: "Place order")
        }
    }
    
}
