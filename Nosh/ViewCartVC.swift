//
//  ViewCartVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 28/02/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation
class ViewCartVC: UITableViewController{
    
    @IBOutlet weak var next: UIBarButtonItem!
    
    var order: PFObject!
    var vendorItems: [PFObject]!
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goto_summary") {
            let svc = segue.destinationViewController as! SummaryVC
            svc.order = self.order
            svc.vendorItems = self.vendorItems
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vendorItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ViewCartCell", forIndexPath: indexPath) as! ViewCartTableViewCell
        var object = vendorItems[indexPath.row]
        cell.title.text = object.valueForKey("title") as? String
        var price = object.valueForKey("price") as? Float
        var count = object.valueForKey("count") as? Int
        if(price != nil){
            var countText = count?.description
            var priceText = String(format: " x $%.2f", price!);
            cell.price.text = countText!+priceText
        }
        cell.detail.text = object.valueForKey("detail") as? String
        cell.layoutIfNeeded()
        return cell

    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let indexPath = tableView.indexPathForSelectedRow();
//        removeItem(indexPath!)
//    }
    
    @IBAction func removeTapped(sender : UIButton) {
        let hitPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let hitIndex = self.tableView.indexPathForRowAtPoint(hitPoint)
        if(hitIndex != nil){
            removeItem(hitIndex!)
        }
    }
    
    func removeItem(hitIndex: NSIndexPath){
        var object = vendorItems[hitIndex.row] as PFObject
        var count = object.valueForKey("count") as? Int
        count = count! - 1
        if(count <= 0){
            vendorItems.removeAtIndex(hitIndex.row)
        }
        object.setValue(count, forKey: "count")
        if(vendorItems.count == 0){
            next.enabled = false
        }
        if(count <= 0){
            self.tableView.reloadData()
        } else {
            var cell = self.tableView.cellForRowAtIndexPath(hitIndex) as! ViewCartTableViewCell
            var price = object.valueForKey("price") as? Float
            if(price != nil){
                var countText = count?.description
                var priceText = String(format: " x $%.2f", price!);
                cell.price.text = countText!+priceText
            }
        }
    }
}