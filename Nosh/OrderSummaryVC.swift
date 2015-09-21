//
//  OrderSummaryVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 06/03/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation
class OrderSummaryVC: UITableViewController{
    
    var order: PFObject!
    var orderItems = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        order = Singleton.sharedInstance().orderForSummary
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.registerClass(SummaryTableViewCell.self, forCellReuseIdentifier: "SummaryCell")
        self.tableView.registerClass(SummaryTableHeadingCell.self, forCellReuseIdentifier: "SummaryCellHeading")
        self.tableView.registerClass(SummaryTableDetailCell.self, forCellReuseIdentifier: "SummaryCellDetail")
        self.tableView.registerClass(SummaryTableAddressCell.self, forCellReuseIdentifier: "SummaryCellAddress")
        NSLog("Object summary loaded : " + order.objectId)
        self.showActivityIndicatory()
        self.order.relationForKey("items").query().findObjectsInBackgroundWithBlock{
            (objects: [AnyObject]!, error: NSError!) -> Void in
            self.hideActivityIndicator()
            if error == nil {
                self.orderItems = objects as! [PFObject]
                self.tableView.reloadData()
            } else {
                self.showError("Failed!", error: error)
            }
        }
        
        NSLog("array count = %i", self.orderItems.count)

        self.tableView.estimatedRowHeight = 119
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int
        if self.orderItems.count == 0 {
            rows = 0
        } else {
            rows = self.orderItems.count + 3
        }
        NSLog("Rows = %i", rows)
        return rows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        NSLog("Table loaded")
        switch indexPath.row{
        case 0:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("SummaryCellHeading", forIndexPath: indexPath) as! SummaryTableHeadingCell
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy, hh:mm a"
            cell.date.text = dateFormatter.stringFromDate(self.order.createdAt)
            
            let vendor = self.order["vendor"] as? PFObject
            NSLog((vendor?.valueForKey("name") as? String)!)
            
            if((vendor) != nil){
                cell.name.text = vendor?.valueForKey("name") as? String
            } else {
                cell.name.text = ""
            }
            var detailsTxt = Util.getAddress(vendor)
            var phone = vendor?.valueForKey("phone") as? String
            if(phone != nil){
                detailsTxt = detailsTxt + " ph: " + phone!
            }
            cell.details.text = detailsTxt
            cell.layoutIfNeeded()
            return cell
        case self.orderItems.count + 1:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("SummaryCellDetail", forIndexPath: indexPath) as! SummaryTableDetailCell
            
            cell.subTotal.text = NSString(format: "$%.2f", order["subTotal"] as! Float) as String
            cell.tax.text = NSString(format: "$%.2f", order["tax"] as! Float) as String
            cell.serviceCharges.text = NSString(format: "$%.2f", order["serviceCharges"] as! Float) as String
            cell.total.text = NSString(format: "$%.2f", order["totalAmount"] as! Float) as String
            return cell
        case self.orderItems.count + 2:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("SummaryCellAddress", forIndexPath: indexPath) as! SummaryTableAddressCell
            
            let user = self.order["user"] as? PFObject
            if(user != nil){
                var address = ""
                var name = user?.valueForKey("name") as? String
                if(name != nil){
                     address += name!
                }
                address += ", " + Util.getAddress()
                var phone = user?.valueForKey("phone") as? String
                if(phone != nil){
                    address = address + " ph: " + phone!
                }
                cell.address.text = address
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("SummaryCell", forIndexPath: indexPath) as! SummaryTableViewCell
            var object = self.orderItems[indexPath.row - 1]
            cell.title.text = object["title"] as? String
            var price = object["price"] as? Float
            var count = object["count"] as? Int
            if(price != nil && count != nil){
                var countText = count!.description
                var priceText = NSString(format: " x $%.2f", price!);
                var totalPrice = price! * Float(count!);
                cell.price.text = countText+(priceText as String)
            } else {
                cell.price.text = ""
            }
            return cell
        }
    }

}
