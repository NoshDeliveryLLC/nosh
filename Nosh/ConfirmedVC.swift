//
//  ConfirmedVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 03/03/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation

class ConfirmedVC: UIViewController {

    @IBOutlet weak var amountLabel: UILabel!

    var order: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.amountLabel.text = String(format: "$%.2f", self.order["totalAmount"] as! Float)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goto_order_summary") {
            let svc = segue.destinationViewController as! OrderSummaryVC
            svc.order = order
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
