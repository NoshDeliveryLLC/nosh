//
//  SummaryWithdrawViewController.swift
//  Nosh
//
//  Created by Michael Kolyadintsev on 03.07.15.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import UIKit

class SummaryWithdrawViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel!
    
    var order: PFObject!
    
    @IBAction func callVendorButton(sender: UIButton) {
        var vendor: PFObject
        vendor = order["vendor"] as! PFObject
        var vendorPhone: String
        vendorPhone = vendor["phone"] as! String
        order.deleteInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                NSLog("", "Order withdraw made")
                // The object has been saved.
                self.callNumber(vendorPhone)
                self.performSegueWithIdentifier("goto_map", sender: self)
            } else {
                // There was a problem, check error.description
                self.showError("Order withdrawing error", error: error!)
            }
        })
    }
    
    @IBAction func withdrawOrderButton(sender: UIButton) {
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
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string:"tel://"+"\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
