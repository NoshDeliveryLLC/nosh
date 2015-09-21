//
//  NotesVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 22/03/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation
class NotesVC: UIViewController {
    
    @IBOutlet var notes : UITextView!
    var order: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notes.layer.borderWidth = 1.0
        self.notes.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.notes.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveTapped(sender : UIButton) {
        self.order["notes"] = self.notes.text as NSString
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func backTapped(sender : UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

}