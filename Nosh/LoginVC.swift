//
//  LoginVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 16/01/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation

class LoginVC: UIViewController {
    
    @IBOutlet var txtUsername : TextField!
    @IBOutlet var txtPassword : TextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtUsername.padding = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
  //      self.txtUsername.content
        self.txtUsername.layer.borderWidth = 0.0
        self.txtUsername.attributedPlaceholder = NSAttributedString(string:"EMAIL",
            attributes:[NSForegroundColorAttributeName: UIColor(hex:"bcbcbc", alpha:1.0),
            NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 18)!])
        
        self.txtPassword.padding = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        self.txtPassword.layer.borderWidth = 0.0
        self.txtPassword.attributedPlaceholder = NSAttributedString(string:"PASSWORD",
            attributes:[NSForegroundColorAttributeName: UIColor(hex:"bcbcbc", alpha:1.0),
                NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 18)!])
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func prefersStatusBarHidden() -> Bool {
//        return navigationController?.navigationBarHidden == true
//    }
    
    @IBAction func forgotPassTapped(sender : UIButton) {
        var alert = UIAlertController(title: "FORGOT PASSWORD", message: "Enter your email to reset password", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            var emailTxt = alert.textFields!.first as UITextField!
            self.showActivityIndicatory()
            PFUser.requestPasswordResetForEmailInBackground(emailTxt.text, block: { (success:Bool, error:NSError!) -> Void in
                self.hideActivityIndicator()
                if(success && error != nil){
                    self.showError("Forgot Password Success!", message: "Please check your email")
                } else{
                    self.showError("Forgot Password Failed!", error: error)
                }
            })
        }))
        var restButton = alert.actions.last as UIAlertAction!
        restButton.enabled = false
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Email Address"
            textField.keyboardType = .EmailAddress
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                restButton.enabled = textField.text != ""
            }
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginTapped(sender : UIButton) {
        var username = txtUsername.text as String?
        var password = txtPassword.text as String?
        
        if (username!.isEmpty || password!.isEmpty ) {
            self.showError("Login Failed!", message: "Please enter Username and Password")
        } else {
            self.showActivityIndicatory()
            PFUser.logInWithUsernameInBackground(username, password:password) {
                (user: PFUser!, error: NSError!) -> Void in
                self.hideActivityIndicator()
                if user != nil {
                    if(self.view.window?.rootViewController?.title == "login"){
                        self.switchRootViewController("SWRevealViewController", animated: true, completion: nil)
                    } else {
                        self.revealViewController().performSegueWithIdentifier("sw_front", sender: self)
                    }
                } else {
                    self.showError("Login Failed!", error: error)
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

}