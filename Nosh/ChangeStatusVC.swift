//
//  ChangeStatusVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 06/03/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation


class ChangeStatusVC: PFQueryTableViewController{
    
    var order: PFObject!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.textKey = "name"
        self.pullToRefreshEnabled = false
        self.paginationEnabled = true
        self.objectsPerPage = 20
        
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        var cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath, object: object)
        var status = self.order["status"] as? PFObject
        if(status != nil && object.objectId == status?.objectId){
            cell.textLabel?.textColor = UIColor.redColor()
        } else {
            cell.textLabel?.textColor = UIColor.blackColor()
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var object = self.objects[indexPath.row] as! PFObject
        if(object.objectId == Constant.OrderStatus.IN_DELIVERY){
            self.order["assignedTo"] = PFUser.currentUser()
        }
        let orderStatusFrom = order["status"] as? PFObject;
        self.order["status"] = object
        self.order.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError!) -> Void in
            if error == nil {
                let statusLog = PFObject(className: "OrderStatusLog")
                statusLog["order"] = self.order;
                statusLog["user"] = PFUser.currentUser();
                statusLog["orderStatusFrom"] = orderStatusFrom;
                statusLog["orderStatusTo"] = object;
                statusLog.saveEventually()
                PFCloud.callFunctionInBackground("sendOrderStatusChangedMail", withParameters: ["orderId": self.order.objectId], block: nil)
                self.tableView.reloadData()
            } else {
                self.showError("Failed!", error: error)
            }
        })
    }
    
    
    override func queryForTable() -> PFQuery! {
        var query = PFQuery(className: "OrderStatus")
        query.orderByAscending("displayOrder")
        return query
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
