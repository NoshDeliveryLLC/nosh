//
//  MenuVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 22/02/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation

class MenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var delivererTableView: UITableView!
    @IBOutlet weak var delivererModeLabel: UILabel!
    @IBOutlet weak var delivererModeSwitcher: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userNameLabel : UILabel!
//    @IBOutlet weak var tableHeightConst : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.delivererTableView.dataSource = self
    }
    
    override func viewWillAppear(animated:Bool) {
        
        super.viewWillAppear(animated)
        //self.tableHeightConst.constant = Util.isDeliverer() ? 250 : 200
//        self.tableHeightConst.constant = 175
        self.view.layoutIfNeeded()
        updateUserName(PFUser.currentUser())
        delivererModeLabel.hidden = Util.isDeliverer() ? false : true
        delivererModeSwitcher.on = Util.isDelivererMode() ? true : false
        delivererModeSwitcher.hidden = Util.isDeliverer() ? false : true
        delivererTableView.hidden = Util.isDelivererMode() ? false : true
    }
    
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func delivererModeChanged(sender: UISwitch) {
        var user = PFUser.currentUser()
        let currentInstallation = PFInstallation.currentInstallation()
        
        if (Util.isDelivererMode()) {
            user["delivererMode"] = false
            delivererTableView.hidden = true
            currentInstallation.removeObject("Deliverer", forKey: "channels")
        } else {
            user["delivererMode"] = true
            delivererTableView.hidden = false
            currentInstallation.addUniqueObject("Deliverer", forKey: "channels")
        }
        user.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                currentInstallation.save()
                NSLog("", "Deliverer mode changed")
                // The object has been saved.
            } else {
                // There was a problem, check error.description
                NSLog("", "Deliverer mode changing error")
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "delivery_orders") {
            let navigationController = segue.destinationViewController as! UINavigationController
            var svc = navigationController.topViewController as! MyOrdersVC
            svc.deliveryOrders = true
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return Util.isDeliverer() ? 5 : 4
        var number: Int
        if tableView.tag == 1 {
            number = 3
        } else {
            number = 1
        }
        return number
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier: String
        if tableView.tag == 1 {
        cellIdentifier = "cell"
        switch indexPath.row{
        case 0:
            cellIdentifier = "newOrder"
        case 1:
           cellIdentifier = "myOrders"
        case 2:
            cellIdentifier = "profile"
//        case 4:
//            cellIdentifier = "deliveryOrders"
        default:
            cellIdentifier = "cell"
            
         }
        } else {
            cellIdentifier = "deliveryOrders"
        }
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        if cellIdentifier == "deliveryOrders" {
            let currentInstallation = PFInstallation.currentInstallation()
            if currentInstallation.badge != 0 {
                cell.imageView?.image = UIImage(named: "dot")
            }
        }
        return cell
    }
    
//    func delivererTableView(delivererTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func delivererTableView(delivererTableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cellIdentifier = "deliveryOrders"
//        var cell = delivererTableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
//        return cell
//    }
    
    
    @IBAction func logoutTapped(sender : UIButton) {
        PFUser.logOut()
        self.performSegueWithIdentifier("goto_login", sender: self)
    }
    
    func updateUserName(user: PFUser!){
        if(user != nil){
            self.userNameLabel.text = user["name"] as? String
        }
    }
    
}
