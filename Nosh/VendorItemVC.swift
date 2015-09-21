//
//  VendorItemVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 28/02/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation
class VendorItemVC: PFQueryTableViewController{
    
    @IBOutlet weak var next: UIBarButtonItem!
    
    var vendor: PFObject!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.pullToRefreshEnabled = false
        self.paginationEnabled = true
        self.objectsPerPage = 20
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.estimatedRowHeight = 89
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        updateNextButton()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("VendorItemHeading", forIndexPath: indexPath) as! VendorItemTableViewHeading
            let banerImage = self.vendor["banerImage"] as? PFFile
            if(banerImage != nil){
                cell.picture.file = banerImage!
                cell.picture.loadInBackground(nil)
            } else {
                cell.picture.hidden = true
            }
            cell.title.text = self.vendor["name"] as? String
            let hours = self.vendor["businessHours"] as? String
            if(hours != nil){
                cell.hours.text = "HOURS: " + hours!
            } else {
                cell.hours.text = ""
            }
            return cell;
        default:
        let cell = tableView.dequeueReusableCellWithIdentifier("VendorItemCell", forIndexPath: indexPath) as! VendorItemTableViewCell
        let object = self.objects[indexPath.row - 1] as! PFObject
        cell.title.text = object.valueForKey("title") as? String
        var price = object.valueForKey("price") as? Float
        if(price != nil){
            cell.price.text = String(format: "$%.2f", price!)
        } else {
            cell.price.text = ""
        }
        cell.detail.text = object.valueForKey("detail") as? String
        var count = object.valueForKey("count") as? Int
        if((count) == nil){
            count = 0
        }
        cell.count.text = count?.description
        if(count == 0){
            cell.count.hidden = true
        } else {
            cell.count.hidden = false
        }
        cell.layoutIfNeeded()
        return cell
        }

    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects == nil ? 1 : self.objects.count + 1
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let indexPath = tableView.indexPathForSelectedRow();
//        if(indexPath?.row > 0){
//            selectItem(indexPath!)
//        }
//    }
    
    override func queryForTable() -> PFQuery! {
        let query = PFQuery(className: "VendorItem")
        query.whereKey("vendor", equalTo:vendor)
        query.whereKeyExists("price")
        query.orderByAscending("displayOrder")
        return query
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goto_view_cart") {
            let svc = segue.destinationViewController as! ViewCartVC
            var order = PFObject(className: "Order")
            order["vendor"] = self.vendor
            
            var totalAmount = 0.0 as Float
            var vendorItems = [PFObject]()
            for object in self.objects {
                var count = object.valueForKey("count") as? Int
                if((count) != nil && count > 0){
                    let price = object.valueForKey("price") as? Float
                    if(count > 0 && price != nil){
                        totalAmount += (Float(count!) * price!)
                    }
                    vendorItems.append(object as! PFObject)
                }
            }
            order["subTotal"] = totalAmount
            var taxAmount = 0 as Float
            var taxRate = self.vendor["taxRate"] as? Float
            if(taxRate != nil){
                taxAmount = totalAmount * (taxRate!/100)
            } else {
                let config = PFConfig.currentConfig()
                if(config != nil && config["default_tax_rate"] != nil){
                    taxRate = config["default_tax_rate"] as? Float
                    taxAmount = totalAmount * (taxRate!/100)
                }
            }
            var scAmount = totalAmount * 0.1
            var baseSC = self.vendor["baseServiceCharges"] as? Float
            if(baseSC != nil){
                scAmount = scAmount + baseSC!
            }
            order["tax"] = taxAmount;
            order["serviceCharges"] = scAmount
            order["totalAmount"] = totalAmount + taxAmount + scAmount
            svc.order = order
            svc.vendorItems = vendorItems
        }
    }
    
    @IBAction func upTapped(sender : UIButton) {
        let hitPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let hitIndex = self.tableView.indexPathForRowAtPoint(hitPoint)
        if(hitIndex != nil){
            selectItem(hitIndex!)
        }
    }
    
    func selectItem(indexPath: NSIndexPath){
        var object = self.objects[indexPath.row - 1] as! PFObject
        var count = object.valueForKey("count") as? Int
        if((count) == nil){
            count = 0
        }
        count = count! + 1
        object.setValue(count, forKey: "count")
 //       self.tableView.reloadData()
        var paths: [NSIndexPath] = [indexPath]
        var cell = self.tableView.cellForRowAtIndexPath(indexPath) as! VendorItemTableViewCell
        cell.count.text = count?.description
        cell.count.hidden = false
        //self.tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Automatic)
        self.next.enabled = true
    }
    
    func updateNextButton(){
        var itemSelected = false
        for object in self.objects {
            var count = object.valueForKey("count") as? Int
            if((count) != nil && count > 0){
                itemSelected = true
                break;
            }
        }
        self.next.enabled = itemSelected
    }
    
}

