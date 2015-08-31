//
//  MyOrdersVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 25/02/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation

class MyOrdersVC: PFQueryTableViewController{

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var navbar: UINavigationItem!
    
    var deliveryOrders = false
    var activeJobs = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 20
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var attr = NSDictionary(object: UIFont(name: "COCOGOOSE", size: 15.0)!, forKey: NSFontAttributeName)
        self.segmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject], forState: UIControlState.Normal)
        
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        if deliveryOrders == false {
            self.segmentedControl.hidden = true
        } else {
            self.segmentedControl.hidden = false
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goto_change_status") {
            var button = sender as! UIButton
            let hitPoint = button.convertPoint(CGPointZero, toView: self.tableView)
            let hitIndex = self.tableView.indexPathForRowAtPoint(hitPoint)
            if(hitIndex != nil){
                var order = self.objects[hitIndex!.row] as! PFObject
                let svc = segue.destinationViewController as! ChangeStatusVC
                svc.order = order
            }
        } else if (segue.identifier == "goto_order_summary") {
            let row = tableView.indexPathForSelectedRow()!.row
            let svc = segue.destinationViewController as! OrderSummaryVC
            var order = self.objects[row] as! PFObject
            NSLog(order.objectId)
            svc.order = order
        }
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyOrderCell", forIndexPath: indexPath) as! OrderTableViewCell
        let vendor = object["vendor"] as? PFObject
        if((vendor) != nil){
            cell.title.text = vendor?.valueForKey("name") as? String
        } else {
            cell.title.text = ""
        }
        let status = object["status"] as? PFObject
        if((status) != nil){
            if(Constant.OrderStatus.UNFILLED == status?.objectId){
               cell.status.textColor = UIColor(hex: "c20000", alpha: 1.0)
            } else {
                cell.status.textColor = UIColor(hex: "63af00", alpha: 1.0)
            }
            cell.status.text = status?.valueForKey("name") as? String
        } else {
            cell.status.text = ""
        }
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a / EEEE MMMM dd, yyyy"
        cell.time.text = dateFormatter.stringFromDate(object.createdAt)
        if(self.deliveryOrders && Util.isDeliverer()){
            if(Constant.OrderStatus.UNFILLED == status?.objectId){
                cell.editStatus.hidden = true
                cell.accept.hidden = false
            } else {
                cell.editStatus.hidden = false
                cell.accept.hidden = true
            }
        } else {
            cell.accept.hidden = true
            cell.editStatus.hidden = true
        }
        return cell
    }
    
    
    override func queryForTable() -> PFQuery! {
        var query:PFQuery
        var user = PFUser.currentUser()
        if(self.deliveryOrders){
            let statusQuery = PFQuery(className: "Order")
            statusQuery.whereKey("status", equalTo: PFObject(withoutDataWithClassName: "OrderStatus", objectId: Constant.OrderStatus.UNFILLED))
            let assignedQuery = PFQuery(className: "Order")
            assignedQuery.whereKey("assignedTo", equalTo: user)
            if activeJobs {
                query = PFQuery.orQueryWithSubqueries([statusQuery, assignedQuery])
            } else {
                query = statusQuery
            }
        } else {
                query = PFQuery(className: "Order")
                query.whereKey("user", equalTo:user)
        }
        query.orderByDescending("createdAt")
        query.includeKey("vendor")
        query.includeKey("status")
        query.includeKey("user")
        return query
    }
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuTapped(sender : UIBarButtonItem) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            self.activeJobs = false
//            self.tableView.reloadData()
            self.viewDidLoad()
        case 1:
            self.activeJobs = true
//            self.tableView.reloadData()
            self.viewDidLoad()
        default:
            break;
        }
    }


    @IBAction func acceptTapped(sender : UIButton) {
        let hitPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let hitIndex = self.tableView.indexPathForRowAtPoint(hitPoint)
        if(hitIndex != nil){
            var order = self.objects[hitIndex!.row] as! PFObject
            let orderStatusFrom = order["status"] as? PFObject;
            order["assignedTo"] = PFUser.currentUser()
            order["status"] = PFObject(withoutDataWithClassName: "OrderStatus", objectId: Constant.OrderStatus.IN_DELIVERY)
            self.showActivityIndicatory()
            order.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError!) -> Void in
                self.hideActivityIndicator()
                if error == nil {
                    let statusLog = PFObject(className: "OrderStatusLog")
                    statusLog["order"] = order;
                    statusLog["user"] = PFUser.currentUser();
                    statusLog["orderStatusFrom"] = orderStatusFrom;
                    statusLog["orderStatusTo"] = order["status"];
                    statusLog.saveEventually()
                    PFCloud.callFunctionInBackground("sendOrderAcceptedMail", withParameters: ["orderId": order.objectId], block: nil)
                    self.tableView.reloadData()
                } else {
                    self.showError("Failed!", error: error)
                }
            })
        }
    }
    
}

