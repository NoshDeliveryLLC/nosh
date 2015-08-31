//
//  SignupVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 16/01/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation

class SignupVC: UIViewController {
    
    @IBOutlet var txtName : UITextField!
    @IBOutlet var txtUsername : UITextField!
    @IBOutlet var txtPhone : UITextField!
    @IBOutlet var txtPassword : UITextField!
    @IBOutlet var txtConfirmPassword : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtName.layer.borderColor = UIColor.lightGrayColor().CGColor
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UITextFieldTextDidBeginEditingNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -getYtoScroll()
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func getYtoScroll() -> CGFloat{
        if(self.txtPhone.isFirstResponder()){
            return self.txtPhone.frame.height + 20
        }
        if(self.txtPassword.isFirstResponder()){
            return self.txtPhone.frame.height + self.txtPassword.frame.height + 40
        }
        if(self.txtConfirmPassword.isFirstResponder()){
            return self.txtPhone.frame.height + self.txtPassword.frame.height + self.txtConfirmPassword.frame.height + 60
        }
        return 0
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goto_address") {
            let navigationController = segue.destinationViewController as! UINavigationController
            var svc = navigationController.topViewController as! AddressVC
            svc.fromSignup = true
        }
    }
    
    @IBAction func signupTapped(sender : UIButton) {
        var name = txtName.text as String
        var username = txtUsername.text as String
        var phone = txtPhone.text as String
        var password = txtPassword.text as String
        var confirm_password = txtConfirmPassword.text as String
        
        if ( name.isEmpty || username.isEmpty || password.isEmpty || phone.isEmpty){
            self.showError("Sign Up Failed!", message: "Please enter Name, Email, Phone and Password")
        } else if ( !password.isEqual(confirm_password) ) {
            self.showError("Sign Up Failed!", message: "Passwords doesn't Match")
        } else {
            
            var user = PFUser()
            user.username = username
            user.password = password
            user.email = username
            // other fields can be set just like with PFObject
            user["name"] = name
            user["phone"] = phone
            user["userRole"] = PFObject(withoutDataWithClassName: "_Role", objectId: Constant.UserRole.CONSUMER)
            view.endEditing(true)
            self.showActivityIndicatory()
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError!) -> Void in
                self.hideActivityIndicator()
                if error == nil {
                    if(self.view.window?.rootViewController?.title == "login"){
                        self.switchRootViewController("SWRevealViewController", animated: true, completion: nil)
                    } else {
                        self.revealViewController().performSegueWithIdentifier("sw_front", sender: self)
                    }
                    
 //                   self.performSegueWithIdentifier("goto_address", sender: self)
                } else {
                    self.showError("Signup Failed!", error: error)
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
}