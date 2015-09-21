//
//  AddressVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 02/03/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation
class AddressVC: UIViewController{
    
    @IBOutlet weak var next: UIButton!
    
    @IBOutlet weak var addressLine1: UITextView!
    
    var fromSignup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressLine1.layer.borderWidth = 1.0
        self.addressLine1.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.addressLine1.text = Util.getAddress()
        self.addressLine1.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func nextTapped(sender : UIBarButtonItem) {
        var currentUser = PFUser.currentUser()
        currentUser.setValue(self.addressLine1.text, forKey: "addressLine1")
        view.endEditing(true)
        self.showActivityIndicatory()
        currentUser.saveInBackgroundWithBlock {
            (succeeded: Bool, error: NSError!) -> Void in
            self.hideActivityIndicator()
            if error == nil {
                self.closeView()
            } else {
                self.showError("Failed!", error: error)
            }
        }
    }
    
    @IBAction func backTapped(sender : UIBarButtonItem) {
        self.closeView()
    }
    
    func closeView(){
        if(self.fromSignup){
            if(self.view.window?.rootViewController?.title == "login"){
                self.switchRootViewController("SWRevealViewController", animated: true, completion: nil)
            } else {
                self.revealViewController().performSegueWithIdentifier("sw_front", sender: self)
            }
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

}
